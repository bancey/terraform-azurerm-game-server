data "azurerm_client_config" "current" {}

locals {
  tags = merge(
    var.tags,
    {
      "application" = var.provisioning_type,
      "environment" = var.env,
    }
  )
  resource_group_name     = var.existing_resource_group_name == null ? azurerm_resource_group.new[0].name : data.azurerm_resource_group.existing[0].name
  resource_group_location = var.existing_resource_group_name == null ? azurerm_resource_group.new[0].location : data.azurerm_resource_group.existing[0].location

  # Map provisioning type to bootstrap script
  bootstrap_script_map = {
    pterodactyl = "bootstrap-pterodactyl.sh"
    pelican     = "bootstrap-pelican.sh"
    crafty      = "bootstrap-crafty.sh"
  }
  bootstrap_script = local.bootstrap_script_map[var.provisioning_type]

  pipeline_kv_policy = [
    {
      tenant_id      = data.azurerm_client_config.current.tenant_id
      object_id      = data.azurerm_client_config.current.object_id
      application_id = null

      certificate_permissions = []
      key_permissions         = []
      storage_permissions     = []
      secret_permissions = [
        "Get",
        "List",
        "Set",
        "Delete",
        "Purge",
      ]
    }
  ]
  all_kv_policies = setunion(local.pipeline_kv_policy, var.kv_policies)
}
