resource "vault_mount" "kvv2" {
  path        = "kvv2"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_backend_v2" "credentials" {
  mount        = vault_mount.kvv2.path
  cas_required = true
}

resource "vault_policy" "credentials_kvv2_access" {
  name = "credentials-kvv2-access"

  policy = <<EOT
path "kvv2" {
  capabilities = ["read", "update", "list", "delete"]
}
EOT
}
