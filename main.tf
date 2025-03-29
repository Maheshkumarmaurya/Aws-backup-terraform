provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  ec2_instance_arn = "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:instance/${var.ec2_instance_id}"
}

resource "aws_backup_vault" "custom_vault" {
  name        = "efs-automatic-backup-vault"  # Valid name
  kms_key_arn = "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:key/36c62245-2edc-4e8e-a08d-07972b45b7a9"
}

resource "aws_iam_role" "backup_role" {
  name = "aws-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "backup.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_backup_plan" "ec2_backup_plan" {
  name = "ec2-backup-plan"

  rule {
    rule_name         = "daily-ec2-backup"
    target_vault_name = aws_backup_vault.custom_vault.name
    schedule          = var.backup_schedule
    start_window      = 60
    completion_window = 120

    lifecycle {
      delete_after = var.retention_days
    }

    recovery_point_tags = {
      Backup = "EC2"
    }
  }
}

resource "aws_backup_selection" "ec2_selection" {
  name         = "ec2-backup-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.ec2_backup_plan.id
  resources    = [local.ec2_instance_arn]
}
