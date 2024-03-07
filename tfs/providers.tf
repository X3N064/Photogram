terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region                   = "ap-northeast-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "terra"
}
