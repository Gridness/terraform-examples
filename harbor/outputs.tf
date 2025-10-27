output "argocd_pass" {
  value     = random_password.argocd_pass.result
  sensitive = true
}

output "argocd_mirror_pass" {
  value     = random_password.argocd_mirror_pass.result
  sensitive = true
}

output "nibop_pass" {
  value     = random_password.nibop_pass.result
  sensitive = true
}
