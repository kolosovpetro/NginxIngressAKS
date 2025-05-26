# NGINX Ingress integration with AKS (including KeyVault Certificates and HTTPS)

## Description

This project demonstrates a secure NGINX Ingress integration with Azure Kubernetes Service (AKS), leveraging
Azure KeyVault for TLS certificate management.
It automates the deployment of a complete HTTPS ingress solution,
where TLS certificates are stored securely in Azure KeyVault
and synced to Kubernetes secrets using the `akv2k8s` controller.

- https://nginx-ingress-test.razumovsky.me

## Overview

The project provisions the following components:

- Azure Kubernetes Service (AKS) cluster with managed identity
- Azure KeyVault for secure TLS certificate storage
- TLS certificate upload and configuration
- NGINX Ingress Controller installed via Helm
- `akv2k8s` (Azure Key Vault to Kubernetes) for syncing secrets and certificates
- PowerShell automation for managing Cloudflare DNS records
- Test Kubernetes deployment with TLS-enabled Ingress

## Deployment order

- terraform plan
- terraform apply
- .\Configure-Nginx-Ingress-HELM.ps1
- .\Configure-Cloudflare-Records.ps1
- .\Configure-Kv-CRD.ps1
- .\Configure-Deployment.ps1

## Configuration

- Deploy AKS cluster with User Assigned Managed Identity (UAMI)
- Deploy Azure KeyVault and import/upload TLS certificate
- Install NGINX Ingress Controller via Helm
- Configure and install akv2k8s Custom Resource Definitions (CRD)
- Provision a test deployment with:
    - ClusterIP service
    - TLS-enabled Ingress using a synced secret from KeyVault
- Automate DNS record creation in Cloudflare via PowerShell scripts

### Node Pool Managed Identity

- **Role**: `Key Vault Secrets User`. **Scope**: Azure KeyVault used for TLS certificates
- **Role**: `Key Vault Certificate User`. **Scope**: Azure KeyVault used for TLS certificates

Note: These roles are necessary for the `akv2k8s` controller to fetch secrets and certificates from KeyVault.

## Notes

- RBAC changes may require several minutes to propagate
- Ensure Azure KeyVault has `public network access` enabled or the AKS subnet is granted access
- The managed identity used by AKS must be assigned roles directly on the KeyVault (not inherited)
- You must have Contributor permissions in the Azure subscription to assign roles

## Prerequisites

- Azure CLI
- Terraform
- Helm v3
- kubectl
- PowerShell Core
- Cloudflare API token with DNS permissions
