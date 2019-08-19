################################################# CREDENTIALS ###############################################
provider "aws" {
  version = "~> 2.13"

  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "us-east-1"
}

provider "template" {
  version = "~> 2.1"
}

############################################ VARIABLES FOR MODULES ##########################################
# A note that secret variables are in secrets.tf
# Non secret variables are here:

variable "test" {
  type = string
  default = "test_variable"
}

################################################### MODULES #################################################
# Quick note - when you modify the modules, you need to run terraform init

module "services" {
  source = "./modules/services"
  test = "${var.test}"
  key_name = "${var.key_name}"
}

module "route53" {
  source = "./modules/route53"
  vpc1_id = "${module.services.vpc1_id}"
}

# module "next_example" {
#   source = "./modules/next_example"
#   input_test = "${module.services.output_test}"
# }
