variable "postgres_major_version" {
  description = "The postgres major version you want to run. The specific major version is then calculated by the module. Example: 16, 17, etc"
  type        = string
}

variable "alarms_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to enable cloudwatch alarms"
}

variable "alarms_sns_topics" {
  type        = list(string)
  default     = null
  description = "List of ARNs for the SNS topics that will be notified when cloudwatch alarms trigger"
  validation {
    condition     = var.alarms_enabled ? var.alarms_sns_topics != null : true
    error_message = "var.alarms_sns_topics is null: If enabling alarms, you should set the SNS topic that is notified"
  }
}

variable "create_security_group" {
  type        = bool
  default     = true
  description = "Whether or not to create a security group for the RDS instance"
}

variable "allow_access_cidr_blocks" {
  description = "List of CIDR strings to allow access on port 5432 to the database"
  type        = list(string)
  default     = null
  validation {
    condition     = var.create_security_group ? var.allow_access_cidr_blocks != null : true
    error_message = "var.allow_access_cidr_blocks is null: If this module is creating the security group, you need to set the allowed cidr blocks"
  }
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID where the security group will be created"
  default     = null
  validation {
    condition     = var.create_security_group ? var.vpc_id != null : true
    error_message = "var.vpc_id is null: If this module is creating the security group, you need to set the vpc_id"
  }
}

variable "admin_username" {
  type        = string
  default     = "root"
  description = "The username for the root/admin account on the RDS instance"
}
