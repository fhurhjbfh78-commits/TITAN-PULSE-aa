$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$html = Join-Path $root 'www\index.html'
if (!(Test-Path $html)) { throw "Missing $html" }
$raw = Get-Content -Raw -Encoding UTF8 $html
$blocks = [regex]::Matches($raw, '(?is)<script\b[^>]*>(.*?)</script>') | Where-Object { $_.Groups[1].Value.Trim().Length -gt 0 }
$i=0
foreach($m in $blocks){
  $i++
  $f = Join-Path $env:TEMP ("titan_pulse_script_{0}.js" -f $i)
  [IO.File]::WriteAllText($f, $m.Groups[1].Value, New-Object Text.UTF8Encoding($false))
  node --check $f
  if($LASTEXITCODE -ne 0){ throw "JavaScript syntax error in block $i" }
}
Write-Host "OK: $i JavaScript blocks passed node --check"
