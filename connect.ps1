$ErrorActionPreference = 'Stop'
$found = @()
$local = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.PrefixOrigin -ne 'WellKnown' } | Select-Object -First 1
if (-not $local) { throw 'IPv4ネットワークが見つかりません。' }
$parts = $local.IPAddress.Split('.')
$prefix = "$($parts[0]).$($parts[1]).$($parts[2])"
1..254 | ForEach-Object {
  $ip = "$prefix.$_"
  if (Test-NetConnection $ip -Port 8022 -InformationLevel Quiet -WarningAction SilentlyContinue) { $ip }
} | ForEach-Object { $found += $_ }
if ($found.Count -eq 0) { throw 'Termux SSH (8022) が見つかりません。同じWi-Fiか、Termuxで sshd が起動しているか確認してください。' }
if ($found.Count -gt 1) { $target = $found | Out-GridView -Title 'Termuxを選択' -PassThru } else { $target = $found[0] }
if ([string]::IsNullOrWhiteSpace($target)) { throw '接続先が選択されませんでした。' }
ssh -p 8022 "$(if ($env:APPMAKER_TERMUX_USER) {$env:APPMAKER_TERMUX_USER} else {'u0_a999'})@$target" 'PATH="$HOME/.local/bin:$PATH"; appmaker'
