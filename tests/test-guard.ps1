# Runs .claude\hooks\guard.ps1 the way Claude Code does (JSON on stdin) against a temporary
# copy of the working folder and checks allow (exit 0) and block (exit 2) for each case.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File tests\test-guard.ps1

$ErrorActionPreference = 'Stop'
$repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$work = Join-Path ([IO.Path]::GetTempPath()) ('ai-academy-guardtest-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Force (Join-Path $work '.claude\hooks'), (Join-Path $work 'data') | Out-Null
Copy-Item (Join-Path $repo '.claude\hooks\guard.ps1') (Join-Path $work '.claude\hooks\guard.ps1')
$guard = Join-Path $work '.claude\hooks\guard.ps1'
$outside = [IO.Path]::GetFullPath((Join-Path $work '..'))
$drive = $work.Substring(0, 1).ToLower()
$msysWork = '/' + $drive + $work.Substring(2).Replace('\', '/')

function Invoke-Guard([string]$json) {
    $psi = New-Object Diagnostics.ProcessStartInfo 'powershell.exe', "-NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$guard`""
    $psi.UseShellExecute = $false
    $psi.RedirectStandardInput = $true
    $psi.RedirectStandardError = $true
    $psi.RedirectStandardOutput = $true
    $p = [Diagnostics.Process]::Start($psi)
    $bytes = [Text.Encoding]::UTF8.GetBytes($json)
    $p.StandardInput.BaseStream.Write($bytes, 0, $bytes.Length)
    $p.StandardInput.Close()
    $err = $p.StandardError.ReadToEnd()
    $p.WaitForExit()
    return @($p.ExitCode, $err.Trim())
}

function Case([string]$expect, [string]$tool, $toolInput, [string]$cwd = $work) {
    $payload = @{ tool_name = $tool; tool_input = $toolInput; cwd = $cwd; hook_event_name = 'PreToolUse' } | ConvertTo-Json -Compress -Depth 5
    return @{ expect = $expect; payload = $payload; label = "$tool $($toolInput | ConvertTo-Json -Compress)" }
}

$cases = @(
    # allowed
    (Case 'allow' 'Read' @{ file_path = "$work\data\a.csv" }),
    (Case 'allow' 'Read' @{ file_path = 'data/a.csv' }),
    (Case 'allow' 'Write' @{ file_path = 'notes/plan.md'; content = 'x' }),
    (Case 'allow' 'Edit' @{ file_path = "$work\README.md" }),
    (Case 'allow' 'Glob' @{ pattern = '**/*.md' }),
    (Case 'allow' 'Grep' @{ pattern = 'C:\\x'; path = 'data' }),
    (Case 'allow' 'Bash' @{ command = 'ls -la data' }),
    (Case 'allow' 'Bash' @{ command = 'python scripts/explore.py data/a.csv' }),
    (Case 'allow' 'Bash' @{ command = 'git log --oneline HEAD~1' }),
    (Case 'allow' 'Bash' @{ command = 'curl -s https://example.org/a/../b' }),
    (Case 'allow' 'Bash' @{ command = "cat $msysWork/data/a.csv > /dev/null" }),
    (Case 'allow' 'PowerShell' @{ command = 'Get-ChildItem data | Select-Object Name' }),
    (Case 'allow' 'PowerShell' @{ command = "Get-Content `"$work\data\a.csv`"" }),
    (Case 'allow' 'WebFetch' @{ url = 'https://code.claude.com/docs/en/hooks' }),
    (Case 'allow' 'WebSearch' @{ query = 'Rule of Two' }),
    (Case 'allow' 'Skill' @{ skill = 'promptotyping' }),
    (Case 'allow' 'Agent' @{ prompt = 'read data' }),
    # blocked: file tools
    (Case 'block' 'Read' @{ file_path = "$outside\secret.txt" }),
    (Case 'block' 'Read' @{ file_path = '../secret.txt' }),
    (Case 'block' 'Read' @{ file_path = '~/Desktop/test.txt' }),
    (Case 'block' 'Read' @{ file_path = '%USERPROFILE%\Desktop\test.txt' }),
    (Case 'block' 'Read' @{ file_path = '\\server\share\x.txt' }),
    (Case 'block' 'Read' @{ file_path = '/c/Windows/win.ini' }),
    (Case 'block' 'Read' @{ file_path = 'C:\PROGRA~1\x.txt' }),
    (Case 'block' 'Read' @{ file_path = "$work-evil\x.txt" }),
    (Case 'block' 'Glob' @{ pattern = '../**/*.txt' }),
    (Case 'block' 'Grep' @{ pattern = 'x'; path = 'C:\Windows' }),
    (Case 'block' 'Write' @{ file_path = '.claude/settings.json'; content = '{}' }),
    (Case 'block' 'Edit' @{ file_path = "$work\.CLAUDE\hooks\guard.ps1" }),
    # blocked: commands
    (Case 'block' 'Bash' @{ command = 'cat ../secret.txt' }),
    (Case 'block' 'Bash' @{ command = 'cat ~/Desktop/test.txt' }),
    (Case 'block' 'Bash' @{ command = 'cat /c/Users/Public/x.txt' }),
    (Case 'block' 'Bash' @{ command = 'cd; ls' }),
    (Case 'block' 'Bash' @{ command = 'cp data/a.csv /tmp/a.csv' }),
    (Case 'block' 'Bash' @{ command = 'rm -rf .claude' }),
    (Case 'block' 'PowerShell' @{ command = 'Get-Content C:\Windows\win.ini' }),
    (Case 'block' 'PowerShell' @{ command = 'Get-Content $env:USERPROFILE\Desktop\test.txt' }),
    (Case 'block' 'PowerShell' @{ command = 'Get-ChildItem $HOME' }),
    (Case 'block' 'PowerShell' @{ command = 'type %APPDATA%\x.txt' }),
    (Case 'block' 'PowerShell' @{ command = 'Get-Content \\server\share\x.txt' }),
    (Case 'block' 'PowerShell' @{ command = 'Invoke-WebRequest file:///C:/Windows/win.ini' }),
    # blocked: connectors, other addresses, session outside
    (Case 'block' 'mcp__gmail__search' @{ q = 'x' }),
    (Case 'block' 'WebFetch' @{ url = 'file:///C:/Windows/win.ini' }),
    (Case 'block' 'Read' @{ file_path = 'data/a.csv' } $outside)
)

$fail = 0
# settings.json must be valid JSON, because Claude Code silently ignores a file it cannot parse.
$settings = Get-Content -Raw (Join-Path $repo '.claude\settings.json') | ConvertFrom-Json
$hook = $settings.hooks.PreToolUse[0].hooks[0]
if ($hook.onFailure -ne 'block' -or $settings.permissions.deny -notcontains 'mcp__*') { $fail++; Write-Output 'FAIL settings.json lacks onFailure block or the MCP deny rule' }
foreach ($c in $cases) {
    $r = Invoke-Guard $c.payload
    $got = if ($r[0] -eq 0) { 'allow' } elseif ($r[0] -eq 2) { 'block' } else { "exit $($r[0])" }
    if ($got -ne $c.expect) { $fail++; Write-Output "FAIL expected $($c.expect), got $got : $($c.label) $($r[1])" }
}
# broken input must block
foreach ($bad in @('', 'not json', '{"tool_input":{}}')) {
    $r = Invoke-Guard $bad
    if ($r[0] -ne 2) { $fail++; Write-Output "FAIL broken input not blocked: '$bad' (exit $($r[0]))" }
}
Remove-Item -LiteralPath $work -Recurse -Force
$total = $cases.Count + 4
Write-Output "$($total - $fail) of $total checks passed"
if ($fail -gt 0) { exit 1 }
