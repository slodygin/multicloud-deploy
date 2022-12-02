module "vpc" {
  source                = "./modules/vpc"
  cluster_name          = "${local.cluster_name}"
}
module "sg" {
  source                = "./modules/sg"
  vpc_id                = "${module.vpc.vpc_id}"
  env_name              = "${var.env_name}"
}
module "eks" {
  source                = "./modules/eks"
  vpc_id                = "${module.vpc.vpc_id}"
  private_subnets       = "${module.vpc.private_subnets}"
  eks_name              = "${var.eks_name}"
  tags                  = "${var.tags}"
  sec_groups            = "${module.sg.sec_groups}"
}
module "elb" {
  source                = "./modules/elb"
  env_name              = "${var.env_name}"
  oidc_provider_arn     = "${module.eks.oidc_provider_arn}"
  cluster_id            = "${module.eks.cluster_id}"
  cluster_name          = "${local.cluster_name}"
  vpc_id                = "${module.vpc.vpc_id}"
}
