# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning v2.0.0](https://semver.org/spec/v2.0.0.html).

## v1.0.0 - In Progress

### Changed

- Deploy AKS cluster
- Deploy Azure KeyVault
- Deploy TLS certificate to Azure KeyVault
- Install NGINX Ingress HELM
- Configure `Cloudflare` DNS records using PowerShell
- Install `akv2k8s` KeyVault CRD
- Configure Node pool managed identity
    - Keyvault RBAC: `Key Vault Secrets User`
    - Keyvault RBAC: `Key Vault Certificate User`
- Configure test deployment with
    - Ingress controller
    - TLS secret
    - ClusterIP service
