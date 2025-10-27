variable "harbor_url" {
  description = "url of harbor server"
  type        = string
  default     = "https://example.com"
}

variable "harbor_user" {
  description = "harbor user"
  type        = string
}

variable "harbor_pass" {
  description = "password of specified harbor user"
  type        = string
}

variable "banner_closable" {
  description = "whether or not the banner message is closable"
  type        = bool
  default     = false
}

variable "banner_message" {
  description = "banner message to display"
  type        = string
  default     = ""
}

variable "banner_type" {
  description = "banner type to display (can be: info, warning, success or danger)"
  type        = string
  default     = "warning"
}

variable "banner_from_date" {
  description = "banner message display start date (format MM/DD/YYYY)"
  type        = string
  default     = ""
}

variable "banner_to_date" {
  description = "banner message display end date (format MM/DD/YYYY)"
  type        = string
  default     = ""
}
