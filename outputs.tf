output "backup_plan_id" {
  value = aws_backup_plan.ec2_backup_plan.id
}

output "backup_selection_id" {
  value = aws_backup_selection.ec2_selection.id
}
