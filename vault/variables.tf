variable "vault_url" {
  description = "url of the vault server"
  type        = string
  default     = "https://example.com"
}

variable "vault_disable_tls" {
  description = "disables tls verification of vault (not recommended!!)"
  type        = bool
  default     = false
}
