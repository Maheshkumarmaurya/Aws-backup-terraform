resource "aws_backup_vault_policy" "root_only_policy" {
  backup_vault_name = aws_backup_vault.custom_vault.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowRootUser"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "backup:GetBackupVaultAccessPolicy",
          "backup:DeleteBackupVaultAccessPolicy",
          "backup:DescribeBackupVault",
          "backup:CopyIntoBackupVault",
          "backup:DeleteRecoveryPoint"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyDeleteRecoveryPointForOthers"
        Effect = "Deny"
        Principal = "*"
        Action = [
          "backup:DeleteRecoveryPoint"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:PrincipalArn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          }
        }
      }
    ]
  })
}
