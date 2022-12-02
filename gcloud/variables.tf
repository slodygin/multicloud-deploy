variable "gcp_project_id" {
  description = "The project ID."
}

variable "region" {
  description = "The region where we'll create your resources (e.g. us-central1)."
}

variable "gcp_zone" {
  description = "The zone where we'll create your resources (e.g. us-central1-b)."
}

variable "name" {
  default = "dev"
  description = "Name for vpc"
}

# Network variables

variable "subnet_cidr" {
  default = "10.240.0.0/24"
  description = "Subnet range"
}
variable "subnet_cidr2" {
  default = "192.168.108.0/22"
  description = "Subnet range"
}
variable "subnet_cidr3" {
  default = "192.168.112.0/22"
  description = "Subnet range"
}
# GKE variables

variable "min_master_version" {
  default     = "1.24.3-gke.200"
  description = "Min GKE master version"
}

variable "node_version" {
  default     = "1.24.3-gke.200"
  description = "GKE node version"
}

variable "gke_num_nodes" {
  default = 1
  description = "Number of nodes in each GKE cluster zone"
}

variable "gke_master_user" {
  default     = "k8s_admin"
  description = "Username to authenticate with the k8s master"
}

variable "gke_master_pass" {
  description = "Username to authenticate with the k8s master"
}

variable "gke_node_machine_type" {
  default     = "e2-highcpu-4"
  description = "Machine type of GKE nodes"
}

variable gke_label {
  default = "dev"
  description = "label"
}
