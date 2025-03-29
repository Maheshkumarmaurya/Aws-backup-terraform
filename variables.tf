variable "aws_region" {
  type        = string
  default     = "ap-south-1"
  description = "AWS region"
}

variable "ec2_instance_id" {
  type        = string
  description = "The EC2 instance ID to back up"
}

variable "backup_schedule" {
  type        = string
  default     = "cron(35 19 * * ? *)"
  description = "Backup schedule in CRON format"
}

variable "retention_days" {
  type        = number
  default     = 1
  description = "Number of days to retain the backup"
}
