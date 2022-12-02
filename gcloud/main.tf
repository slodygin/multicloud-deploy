terraform {
  backend "http" {
  }
}

provider "google" {
   credentials = "${file("./service-account.json")}"
   project     = "k8s-testing-361606"
 }


module "vpc" {
  source                = "./modules/vpc"
  gcp_project_id        = "${var.gcp_project_id}"
}

module "subnet" {
  source                = "./modules/subnet"
  region                = "${var.region}"
  vpc_name              = "${module.vpc.vpc_name}"
  subnet_cidr           = "${var.subnet_cidr}"
  subnet_cidr2          = "${var.subnet_cidr2}"
  subnet_cidr3          = "${var.subnet_cidr3}"
  gcp_project_id        = "${var.gcp_project_id}"
}



module "gke" {
  source                = "./modules/gke"
  region                = "${var.region}"
  min_master_version    = "${var.min_master_version}"
  node_version          = "${var.node_version}"
  gke_num_nodes         = "${var.gke_num_nodes}"
  vpc_name              = "${module.vpc.vpc_name}"
  subnet_name           = "${module.subnet.subnet_name}"
  subnet_name2          = "${module.subnet.subnet_name2}"
  subnet_name3          = "${module.subnet.subnet_name3}"
  gke_master_user       = "${var.gke_master_user}"
  gke_master_pass       = "${var.gke_master_pass}"
  gke_node_machine_type = "${var.gke_node_machine_type}"
  gke_label             = "${var.gke_label}"
  gcp_project_id        = "${var.gcp_project_id}"
}

