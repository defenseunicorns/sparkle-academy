variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "user_id" {
  description = "User ID, this will ensure sparkles don't step on each other's resources"
  type        = string
}
