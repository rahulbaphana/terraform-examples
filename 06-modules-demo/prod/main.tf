terraform {
  required_version = "> 0.9.0"

  backend "s3" {
    region  = "us-east-2"
    bucket  = "terraform-lock-bucket"
    key = "prod_terraform_spring_boot_app.tfstate"
    encrypt = "true"
    lock_table = "Spring-Boot-Lock-Table"
  }
}

module "spring-app-module" {
  source = "../shared_module"
  instance_type = "m3.medium"
}
