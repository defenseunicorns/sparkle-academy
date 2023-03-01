variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "user_id" {
  description = "User ID, this will ensure sparkles don't step on each other's resources"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use in the EKS cluster"
  type = string
  default = "1.25"
}

variable "instance_type" {
  description = "AWS Instance type to use for nodes"
  type = string
  default = "t3.small"
}