resource "azurerm_virtual_machine_extension" "customscript" {
  name                       = "BootstrapVM"
  virtual_machine_id         = azurerm_linux_virtual_machine.this.id
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = 2.1
  auto_upgrade_minor_version = false
  protected_settings         = <<PROTECTED_SETTINGS
  {
    "script": "${base64encode(templatefile("${path.module}/provision/${local.bootstrap_script}", { domain = "${var.certificate_config.domain_name}", email = "${var.certificate_config.email}" }))}"
  }
  PROTECTED_SETTINGS

  tags = local.tags
}

resource "azurerm_virtual_machine_extension" "aadlogin" {
  count                      = var.enable_aad_login ? 1 : 0
  name                       = "AADSSHLoginForLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.this.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}
