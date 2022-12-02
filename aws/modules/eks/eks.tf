variable "private_subnets" {
  description = "Netwrok name"
}

variable "vpc_id" {
  description = "Netwrok name"
}
variable "eks_name" {
  description = "EKS name"
}
variable "tags" {
  description = "Tags"
}
variable "sec_groups" {
  description = "sec_groups"
}

module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "18.19.0"

    cluster_name                    = var.eks_name
    cluster_version                 = "1.21"
    cluster_endpoint_private_access = true
    cluster_endpoint_public_access  = true
    cluster_additional_security_group_ids = [var.sec_groups.id]

    vpc_id     = var.vpc_id
    subnet_ids = var.private_subnets

    eks_managed_node_group_defaults = {
      ami_type               = "AL2_x86_64"
      disk_size              = 50
      instance_types         = ["t3.medium", "t3.large"]
      vpc_security_group_ids = [var.sec_groups.id]
    }

    eks_managed_node_groups = {
      green = {
        min_size     = 1
        max_size     = 10
        desired_size = 3

        instance_types = ["t3.medium"]
        capacity_type  = "SPOT"
        labels = var.tags 
        taints = {
        }
        tags = var.tags
      }
    }

    tags = var.tags
  }


output "oidc_provider_arn" {
  value       = "${module.eks.oidc_provider_arn}"
  description = "arn of k8s"
}
output "cluster_id" {
  value       = "${module.eks.cluster_id}"
  description = "cluster_id"
}


