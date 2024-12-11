locals {
  engine_version = coalesce(var.engine_version, data.aws_rds_engine_version.this.version_actual)
  family         = coalesce(var.family, data.aws_rds_engine_version.this.parameter_group_family)
  security_group_ids = concat(
    var.vpc_security_group_ids,
    module.this.enabled && var.create_security_group ? [aws_security_group.this[0].id] : []
  )
}

data "aws_rds_engine_version" "this" {
  engine  = "postgres"
  version = var.postgres_major_version
  latest  = true
}
resource "aws_security_group" "this" {
  count  = module.this.enabled && var.create_security_group ? 1 : 0
  vpc_id = var.vpc_id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allow_access_cidr_blocks
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = module.this.tags
}

module "db" {
  source                                                 = "terraform-aws-modules/rds/aws"
  version                                                = "6.10.0"
  count                                                  = module.this.enabled ? 1 : 0
  allocated_storage                                      = var.allocated_storage
  max_allocated_storage                                  = var.max_allocated_storage
  allow_major_version_upgrade                            = var.allow_major_version_upgrade
  auto_minor_version_upgrade                             = var.auto_minor_version_upgrade
  apply_immediately                                      = var.apply_immediately
  backup_retention_period                                = var.backup_retention_period
  backup_window                                          = var.backup_window
  create_db_option_group                                 = false
  create_db_subnet_group                                 = true
  create_monitoring_role                                 = true
  deletion_protection                                    = var.deletion_protection_enabled
  engine                                                 = "postgres"
  engine_version                                         = local.engine_version
  family                                                 = local.family
  identifier                                             = module.this.id
  instance_class                                         = var.instance_class
  kms_key_id                                             = var.kms_key_id
  maintenance_window                                     = var.maintenance_window
  major_engine_version                                   = var.major_engine_version
  manage_master_user_password                            = true
  manage_master_user_password_rotation                   = var.manage_master_user_password_rotation
  master_user_password_rotate_immediately                = var.master_user_password_rotate_immediately
  master_user_password_rotation_automatically_after_days = var.master_user_password_rotation_automatically_after_days
  master_user_password_rotation_duration                 = var.master_user_password_rotation_duration
  master_user_password_rotation_schedule_expression      = var.master_user_password_rotation_schedule_expression
  master_user_secret_kms_key_id                          = var.kms_key_id
  storage_type                                           = var.storage_type
  iops                                                   = var.iops
  monitoring_interval                                    = var.monitoring_interval
  monitoring_role_name                                   = "AllowRDSMonitoringFor-${module.this.id}"
  multi_az                                               = false
  iam_database_authentication_enabled                    = var.iam_database_authentication_enabled
  port                                                   = "5432"
  skip_final_snapshot                                    = var.skip_final_snapshot
  snapshot_identifier                                    = var.snapshot_identifier
  storage_encrypted                                      = true
  subnet_ids                                             = var.subnet_ids
  username                                               = var.admin_username
  vpc_security_group_ids                                 = local.security_group_ids
  tags                                                   = module.this.tags
}

module "rds_alarms" {
  source            = "lorenzoaiello/rds-alarms/aws"
  version           = "2.4.1"
  count             = module.this.enabled && var.alarms_enabled ? 1 : 0
  db_instance_id    = module.db[0].db_instance_resource_id
  db_instance_class = var.instance_class
  prefix            = "${module.this.id}-"
  actions_alarm     = var.alarms_sns_topics
  actions_ok        = var.alarms_sns_topics
  engine            = "postgres"
  tags              = module.this.tags
}

data "aws_secretsmanager_secret" "db" {
  count = module.this.enabled ? 1 : 0
  arn   = module.db[0].db_instance_master_user_secret_arn
}
