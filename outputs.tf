output "this" {
  description = "Reach into here if you need something specific we don't expose"
  value       = try(module.db[0], "")
}

output "admin_username" {
  description = "The master username for the database"
  value       = module.db[0].db_instance_username
  sensitive   = true
}

output "address" {
  description = "The address of the RDS instance"
  value       = try(module.db[0].db_instance_address, null)
}

output "port" {
  description = "The database port"
  value       = try(module.db[0].db_instance_port, null)
}

output "ca_cert_identifier" {
  description = "Specifies the identifier of the CA certificate for the DB instance"
  value       = try(module.db[0].db_instance_ca_cert_identifier, null)
}

output "arn" {
  description = "The ARN of the RDS instance"
  value       = try(module.db[0].db_instance_arn, null)
}

output "availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = try(module.db[0].db_instance_availability_zone, null)
}

output "endpoint" {
  description = "The connection endpoint"
  value       = try(module.db[0].db_instance_endpoint, null)
}

output "identifier" {
  description = "The RDS instance identifier"
  value       = try(module.db[0].db_instance_identifier, null)
}

output "resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = try(module.db[0].db_instance_resource_id, null)
}

output "status" {
  description = "The RDS instance status"
  value       = try(module.db[0].db_instance_status, null)
}

output "name" {
  description = "The database name"
  value       = try(module.db[0].db_instance_name, null)
}

output "master_user_secret_name" {
  description = "The name of the master user secret"
  value       = module.this.enabled ? data.aws_secretsmanager_secret.db[0].name : null
}

output "master_user_secret_arn" {
  description = "The ARN of the master user secret"
  value       = module.this.enabled ? module.db[0].db_instance_master_user_secret_arn : null
}

data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

output "db_iam_dbuser_arn_prefix" {
  description = <<EOT
The resource ARN prefix for a db user to connect with IAM database authentication. You should append `/your-iam-db-user` to this value.
As per: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.IAMPolicy.html
EOT
  value       = module.this.enabled ? "arn:aws:rds-db:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:dbuser:${module.db[0].db_instance_resource_id}" : null
}
