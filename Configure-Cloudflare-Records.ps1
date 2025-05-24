# Requires Install-Module -Name CloudflareDnsTools -Scope AllUsers

$ErrorActionPreference = "Stop"

$zoneName = "razumovsky.me"

$ingressService = $( kubectl get service "my-ingress-ingress-nginx-controller" -n "ingress" -o json ) | ConvertFrom-Json
$ingressPublicIp = $ingressService.status.loadBalancer.ingress[0].ip

Write-Warning "Public IP: $ingressPublicIp"

$newDnsEntriesHashtable = @{ }

$newDnsEntriesHashtable["nginx-ingress-test.$zoneName"] = $ingressPublicIp

Set-CloudflareDnsRecord `
    -ApiToken $env:CLOUDFLARE_API_KEY `
    -ZoneName $zoneName `
    -NewDnsEntriesHashtable $newDnsEntriesHashtable
