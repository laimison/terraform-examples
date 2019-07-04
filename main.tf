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
# A note that secret variables are in secrets.tf file

variable "test" {
  type = string
  default = "test_variable"
}

################################################### MODULES #################################################
# When modifying modules, you need to run terraform init

module "services" {
  source = "./modules/services"
  test = "${var.test}"
  key_name = "${var.key_name}"
}

# module "next_example" {
#   source = "./modules/next_example"
#   input_test = "${module.services.output_test}"
# }
