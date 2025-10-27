output "terraform_bucket_minio_id" {
  description = "ID of the terraform bucket"
  value       = var.verbose == true ? minio_s3_bucket.terraform.id : null
}

output "backup_bucket_minio_id" {
  description = "ID of the backup bucket"
  value       = var.verbose == true ? minio_s3_bucket.backup.id : null
}

output "terraform_bucket_minio_url" {
  description = "URL of the terraform bucket"
  value       = var.verbose == true ? minio_s3_bucket.terraform.bucket_domain_name : null
}

output "backup_bucket_minio_url" {
  description = "URL of the backup bucket"
  value       = var.verbose == true ? minio_s3_bucket.backup.bucket_domain_name : null
}

output "devops_user_group" {
  description = "Name of the DevOps user group"
  value       = var.verbose == true ? minio_iam_group.devops.group_name : null
}

output "worker_user_group" {
  description = "Name of the worker user group"
  value       = var.verbose == true ? minio_iam_group.worker.group_name : null
}

output "devops_group_users" {
  description = "Members of DevOps user group"
  value       = var.verbose == true ? minio_iam_group_membership.devops.users : null
}

output "worker_group_users" {
  description = "Members of worker user group"
  value       = var.verbose == true ? minio_iam_group_membership.worker.users : null
}

output "access_terraform_state_group_policy_id" {
  description = "ID of access_terraform_state group policy"
  value       = var.verbose == true ? minio_iam_group_policy.access_terraform_state.id : null
}

output "access_backup_group_policy_id" {
  description = "ID of backup group policy"
  value       = var.verbose == true ? minio_iam_group_policy.access_backup.id : null
}

output "access_terraform_state_group_policy_policy" {
  description = "Policy of access_terraform_state group policy"
  value       = var.verbose == true ? minio_iam_group_policy.access_terraform_state.policy : null
}

output "access_backup_group_policy_policy" {
  description = "Policy of backup group policy"
  value       = var.verbose == true ? minio_iam_group_policy.access_backup.policy : null
}

output "longhorn_user" {
  description = "username of longhorn user service account"
  value       = var.verbose_users == true ? minio_iam_service_account.longhorn.access_key : null
}

output "longhorn_pass" {
  description = "password of longhorn user service account"
  value       = var.verbose_users == true ? minio_iam_service_account.longhorn.secret_key : null
  sensitive   = true
}

output "harbor_user" {
  description = "username of harbor user service account"
  value       = var.verbose_users == true ? minio_iam_service_account.harbor.access_key : null
}

output "harbor_pass" {
  description = "password of harbor user service account"
  value       = var.verbose_users == true ? minio_iam_service_account.harbor.secret_key : null
  sensitive   = true
}
