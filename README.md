## DNS

- https://nginx-ingress-test.razumovsky.me

## Deployment order

- terraform plan
- terraform apply
- .\Configure-Nginx-Ingress-HELM.ps1
- .\Configure-Cloudflare-Records.ps1
- .\Configure-Kv-CRD.ps1
- .\Configure-Kv-Nodepool-RBAC.ps1
