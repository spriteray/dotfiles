if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$tcpPorts = @(22, 8001, 8010, 8012, 8013, 8101, 9029, 20006)
$udpPorts = @(9029)

$wslIP = wsl -- hostname -I
$wslIP = $wslIP.Trim()

wsl -u root -- service ssh start
wsl -u root -- sysctl -p

foreach ($port in $tcpPorts) {
    netsh interface portproxy add v4tov4 listenport=$port connectaddress=$wslIP connectport=$port
    $ruleName = "Allow WSL Inbound TCP $port"
    Remove-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
    New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Action Allow -Protocol TCP -LocalPort $port
}

foreach ($port in $udpPorts) {
    $ruleName = "Allow WSL Inbound UDP $port"
    Remove-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
    New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Action Allow -Protocol UDP -LocalPort $port
}

Write-Host "Done!"
pause