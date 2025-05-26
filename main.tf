data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

#################################################################################################################
# LOCALS
#################################################################################################################

locals {
  vnet_cidr       = ["10.10.0.0/24"]
  aks_subnet_cidr = ["10.10.0.64/26"]

}

#################################################################################################################
# RESOURCE GROUP
#################################################################################################################

resource "azurerm_resource_group" "public" {
  location = var.location
  name     = "rg-aks-nginx-${var.prefix}"
  tags     = var.tags
}

#################################################################################################################
# VNET AND SUBNET
#################################################################################################################

resource "azurerm_virtual_network" "public" {
  name                = "vnet-${var.prefix}"
  address_space       = local.vnet_cidr
  location            = azurerm_resource_group.public.location
  resource_group_name = azurerm_resource_group.public.name
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks-${var.prefix}"
  resource_group_name  = azurerm_resource_group.public.name
  virtual_network_name = azurerm_virtual_network.public.name
  address_prefixes     = local.aks_subnet_cidr
}

#################################################################################################################
# AKS
#################################################################################################################

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.prefix}"
  location            = azurerm_resource_group.public.location
  resource_group_name = azurerm_resource_group.public.name
  dns_prefix          = "aks-${var.prefix}"

  default_node_pool {
    name           = "default"
    node_count     = 2
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.aks.id
    type           = "VirtualMachineScaleSets"

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }
}

data "azurerm_kubernetes_cluster" "aks" {
  name                = azurerm_kubernetes_cluster.aks.name
  resource_group_name = azurerm_resource_group.public.name

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

##########################################################################
# KEYVAULT
##########################################################################

resource "azurerm_key_vault" "public" {
  name                        = "kv-aks-${var.prefix}"
  location                    = azurerm_resource_group.public.location
  resource_group_name         = azurerm_resource_group.public.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enable_rbac_authorization   = true
  sku_name                    = "standard"
}

##########################################################################
# RBAC KEYVAULT
##########################################################################

resource "azurerm_role_assignment" "kv_cli_rbac" {
  scope                = azurerm_key_vault.public.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "kv_azure_portal_rbac" {
  scope                = azurerm_key_vault.public.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = "89ab0b10-1214-4c8f-878c-18c3544bb547"
}

##########################################################################
# RBAC KEYVAULT FOR AKS
##########################################################################

resource "azurerm_role_assignment" "aks_kubelet_rbac_certificates" {
  scope                = azurerm_key_vault.public.id
  role_definition_name = "Key Vault Certificate User"
  principal_id         = data.azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

  depends_on = [
    azurerm_role_assignment.kv_cli_rbac,
    azurerm_kubernetes_cluster.aks
  ]
}

resource "azurerm_role_assignment" "aks_kubelet_rbac_secrets" {
  scope                = azurerm_key_vault.public.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

  depends_on = [
    azurerm_role_assignment.kv_cli_rbac,
    azurerm_kubernetes_cluster.aks
  ]
}

##########################################################################
# SECRETS
##########################################################################

resource "azurerm_key_vault_certificate" "imported" {
  name         = "razumovsky-certificate"
  key_vault_id = azurerm_key_vault.public.id

  certificate {
    contents = filebase64("${path.root}/wildcard_22_Aug_2025_razumovsky.me.pfx")
    password = file("${path.root}/password.txt")
  }

  depends_on = [
    azurerm_role_assignment.kv_cli_rbac,
    azurerm_role_assignment.kv_azure_portal_rbac
  ]
}
