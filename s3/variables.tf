variable "minio_user" {
  description = "minio s3 user"
  type        = string
}

variable "minio_pass" {
  description = "password of specified minio s3 user"
  type        = string
}

variable "minio_ssl" {
  description = "s3 ssl mode (disabling this is not recommended!)"
  type        = bool
  default     = true
}

variable "minio_default_admin" {
  description = "username of default minio s3 admin"
  type        = string
  default     = "admin"
}

variable "verbose" {
  description = "enables verbouse output"
  type        = bool
  default     = false
}

variable "verbose_users" {
  description = "enables output of provisioned service accounts data"
  type        = bool
  default     = true
}
