# PreToolUse guard for an AI Academy working folder.
# Keeps Claude Code's file tools and terminal commands inside the folder that contains
# .claude\hooks\guard.ps1, blocks connectors (MCP) and protects the .claude folder.
# Web access stays allowed. Skills, subagents and normal scripts stay allowed.
#
# Fail closed: anything other than the final "exit 0" ends with exit code 2, which blocks
# the tool call. settings.json sets onFailure "block", so a missing script, a failed start
# or a timeout block as well.
#
# Limit: terminal commands are checked as text. A script that builds a path at runtime is
# not seen. The operating-system sandbox of Claude Code is not available on native Windows.
#
# Runs on the built-in Windows PowerShell 5.1. Messages avoid umlauts on purpose, because
# PowerShell 5.1 does not write UTF-8 to stderr by default.

$ErrorActionPreference = 'Stop'

function Block([string]$reason) {
    [Console]::Error.WriteLine("Gesperrt (Arbeitsordner): $reason")
    exit 2
}

function Get-Prop($obj, [string]$name) {
    if ($null -eq $obj) { return $null }
    $p = $obj.PSObject.Properties[$name]
    if ($null -eq $p) { return $null }
    return $p.Value
}

# The folder is derived from the script location, never from the tool input.
$Root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..')).TrimEnd('\')
$ClaudeDir = $Root + '\.claude'

function Test-Inside([string]$full) {
    return ($full -ieq $Root) -or $full.StartsWith($Root + '\', [StringComparison]::OrdinalIgnoreCase)
}

# Returns $null if the path text points inside the folder, otherwise a reason.
function Test-PathText([string]$s, [string]$base, [bool]$forWrite) {
    if ($null -eq $s) { return $null }
    $s = $s.Trim().Trim('"').Trim("'")
    if ($s -eq '') { return $null }
    if ($s -match '^~|[\\/]~|~\d') { return "Home-Ordner oder Kurzname im Pfad: $s" }
    if ($s -match '%[A-Za-z_][A-Za-z0-9_]*%|\$') { return "Umgebungsvariable im Pfad: $s" }
    if ($s -match '^(\\\\|//)') { return "Netzwerkpfad: $s" }
    if ($s -match '^/([A-Za-z])(/.*)?$') {
        # Git Bash style /c/Users/... becomes C:/Users/...
        $rest = $Matches[2]; if (-not $rest) { $rest = '/' }
        $s = $Matches[1] + ':' + $rest
    } elseif ($s -match '^[\\/]') {
        return "Pfad ab Laufwerkswurzel: $s"
    }
    $full = [IO.Path]::GetFullPath([IO.Path]::Combine($base, $s)).TrimEnd('\', '/')
    if (-not (Test-Inside $full)) { return "Pfad ausserhalb des Arbeitsordners: $full" }
    if ($forWrite -and (($full -ieq $ClaudeDir) -or $full.StartsWith($ClaudeDir + '\', [StringComparison]::OrdinalIgnoreCase))) {
        return 'Der Ordner .claude ist schreibgeschuetzt'
    }
    return $null
}

# Returns $null if the command text stays inside the folder, otherwise a reason.
function Test-Command([string]$cmd, [string]$base) {
    # Web addresses are allowed and must not trigger the path checks below.
    $c = [regex]::Replace($cmd, '(?i)\bhttps?://[^\s''"]+', ' ')
    if ($c -match '(?i)\bfile:') { return 'file:-Adressen' }
    if ($c -match '(^|[\s/\\''"=(])\.\.([/\\\s''");]|$)') { return "'..' fuehrt aus dem Arbeitsordner" }
    if ($c -match '(^|[\s''"=(])~') { return "'~' steht fuer den Home-Ordner" }
    if ($c -match '%[A-Za-z_][A-Za-z0-9_]*%') { return 'Umgebungsvariable (%VAR%)' }
    if ($c -match '(?i)\$env:|\$\{?(HOME|USERPROFILE|HOMEDRIVE|HOMEPATH|APPDATA|LOCALAPPDATA|TEMP|TMP|OLDPWD)\b') { return 'Umgebungsvariable mit Pfad' }
    if ($c -match '(^|[\s''"=(])\\\\[^\s]') { return 'Netzwerkpfad' }
    if ($c -match '(?i)(^|[\s/\\''"=(])\.claude([/\\\s''");]|$)') { return 'Der Ordner .claude ist geschuetzt' }
    # Bare cd goes to the home folder in Git Bash.
    if ($c -match '(?i)(^|[;&|]\s*)(cd|chdir)\s*($|[;&|])') { return "'cd' ohne Ziel fuehrt in den Home-Ordner" }
    foreach ($m in [regex]::Matches($c, '(?<![A-Za-z0-9_])[A-Za-z]:[\\/][^\s''"|;&<>()]*')) {
        $why = Test-PathText $m.Value $base $false
        if ($why) { return $why }
    }
    foreach ($m in [regex]::Matches($c, '(?<=^|[\s''"=(>])/[^\s''"|;&<>()]*')) {
        $t = $m.Value
        if ($t -match '^/dev/(null|stdout|stderr)$') { continue }
        $why = Test-PathText $t $base $false
        if ($why) { return $why }
    }
    return $null
}

try {
    $stdin = [Console]::OpenStandardInput()
    $ms = New-Object IO.MemoryStream
    $stdin.CopyTo($ms)
    $text = [Text.Encoding]::UTF8.GetString($ms.ToArray()).TrimStart([char]0xFEFF)
    if ([string]::IsNullOrWhiteSpace($text)) { Block 'leere Eingabe' }
    $data = $text | ConvertFrom-Json
    $tool = [string](Get-Prop $data 'tool_name')
    $ti = Get-Prop $data 'tool_input'
    if ($tool -eq '') { Block 'Werkzeugname fehlt' }

    # Relative paths resolve against the session's working directory, which must be inside.
    $base = $Root
    $cwd = [string](Get-Prop $data 'cwd')
    if ($cwd) {
        $cwdFull = [IO.Path]::GetFullPath($cwd).TrimEnd('\', '/')
        if (-not (Test-Inside $cwdFull)) { Block "Claude Code arbeitet ausserhalb des Arbeitsordners ($cwdFull). Bitte im Ordner neu starten." }
        $base = $cwdFull
    }

    if ($tool -like 'mcp__*') { Block "Konnektoren (MCP) sind gesperrt: $tool" }

    $read = @{ 'Read' = 'file_path'; 'NotebookRead' = 'notebook_path'; 'LS' = 'path'; 'Glob' = 'path'; 'Grep' = 'path' }
    $write = @{ 'Write' = 'file_path'; 'Edit' = 'file_path'; 'MultiEdit' = 'file_path'; 'NotebookEdit' = 'notebook_path' }

    if ($read.ContainsKey($tool)) {
        $why = Test-PathText ([string](Get-Prop $ti $read[$tool])) $base $false
        if ($why) { Block $why }
        foreach ($k in @('pattern', 'glob')) {
            if ($tool -eq 'Grep' -and $k -eq 'pattern') { continue }
            $g = [string](Get-Prop $ti $k)
            if ($g -match '\.\.|^[A-Za-z]:|^[\\/]|^~|\$|%') { Block "Suchmuster reicht aus dem Arbeitsordner: $g" }
        }
    } elseif ($write.ContainsKey($tool)) {
        $why = Test-PathText ([string](Get-Prop $ti $write[$tool])) $base $true
        if ($why) { Block $why }
    } elseif ($tool -eq 'Bash' -or $tool -eq 'PowerShell') {
        $why = Test-Command ([string](Get-Prop $ti 'command')) $base
        if ($why) { Block $why }
    } elseif ($tool -eq 'WebFetch') {
        if ([string](Get-Prop $ti 'url') -notmatch '(?i)^https?://') { Block 'nur http- und https-Adressen' }
    }
    # All other tools (web search, skills, subagents, task lists) stay allowed.
} catch {
    Block "Fehler im Hook, daher gesperrt: $($_.Exception.Message)"
}
exit 0
