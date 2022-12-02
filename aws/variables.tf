variable "env_name" {
  description = "Env name"
  type        = string
  default     = "dev"
}
variable "tags" {
  description = "Tags name"
  default     = {
    tag1="dev1"
  } 
}
locals {
  eks_name = "learning-k8s"
}
variable "eks_name" {
  description = "Env name"
  type        = string
  default     = "learning-k8s"
}
variable "cluster_name" {
  description = "Env name"
  type        = string
  default     = "learning-k8s"
}
locals {
  cluster_name = "learning-k8s"
}