################
# INPUTS
################
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnets_cidr" {
  type    = string
  default = "10.0.0.0/22"
}

################
# VPC
################

data "aws_availability_zones" "this" {
  state = "available"
}

locals {
  availability_zones = sort(slice(data.aws_availability_zones.this.names, 0, 2))
}

module "vpc" {
  source                           = "cloudposse/vpc/aws"
  version                          = "2.2.0"
  ipv4_primary_cidr_block          = var.vpc_cidr
  assign_generated_ipv6_cidr_block = false
  context                          = module.this.context
  attributes                       = ["vpc"]
}

module "subnets" {
  source                          = "cloudposse/dynamic-subnets/aws"
  version                         = "2.4.2"
  max_subnet_count                = 2
  availability_zones              = local.availability_zones
  vpc_id                          = module.vpc.vpc_id
  igw_id                          = [module.vpc.igw_id]
  ipv4_cidr_block                 = [var.subnets_cidr]
  ipv4_enabled                    = true
  ipv6_enabled                    = false
  nat_gateway_enabled             = false
  nat_instance_enabled            = false
  public_subnets_additional_tags  = { "Visibility" : "Public" }
  private_subnets_additional_tags = { "Visibility" : "Private" }
  metadata_http_endpoint_enabled  = true
  metadata_http_tokens_required   = true
  public_subnets_enabled          = true
  context                         = module.this.context
  attributes                      = ["vpc", "subnet"]
}

################
# RDS / DB
################

module "label_db" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = ["db"]
  context    = module.this.context
}

module "db" {
  source                              = "../../"
  context                             = module.label_db.context
  allocated_storage                   = 20
  allow_access_cidr_blocks            = module.subnets.private_subnet_cidrs
  apply_immediately                   = true
  backup_retention_period             = 1
  deletion_protection_enabled         = false
  postgres_major_version              = "17"
  iam_database_authentication_enabled = true
  instance_class                      = "db.t3.medium"
  skip_final_snapshot                 = true
  alarms_enabled                      = false
  alarms_sns_topics                   = []
  create_security_group               = true
  subnet_ids                          = module.subnets.private_subnet_ids
  vpc_id                              = module.vpc.vpc_id
}

################
# OUTPUTS
################


output "vpc" {
  value = module.vpc
}

output "subnets" {
  value = module.subnets
}

output "db" {
  value = module.db
}
