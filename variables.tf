variable "vpc_cidr_block" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "database_name" {
  type = string
}

variable "database_username" {
  type = string
}

variable "database_password" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "allocated_storage" {
  type = number
}

variable "family" {
  type = string
}

variable "major_engine_version" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "deletion_protection_enabled" {
  type = bool
}

variable "skip_final_snapshot" {
  type = bool
}

variable "allow_major_version_upgrade" {
  type = bool
}

variable "apply_immediately" {
  type = bool
}

variable "backup_retention_period" {
  type = number
}

variable "maintenance_window" {
  default = "Mon:00:00-Mon:03:00"
  type    = string
}

variable "backup_window" {
  default = "03:00-06:00"
  type    = string
}

variable "monitoring_interval" {
  default = "60"
  type    = string
}

variable "region_settings_params_enabled" {
  type        = bool
  default     = true
  description = "When enabled the connection information (except password) is stored in SSM Param Store region settings for this deployment"
}
