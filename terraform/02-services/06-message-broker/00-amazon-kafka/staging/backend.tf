terraform {
  required_version = "~> 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.46.0"
    }
  }

  backend "s3" {
    profile        = "default"
    bucket         = "terraform-state"
    region         = "ap-southeast-1"
    key            = "amazon-kafka/staging.tfstate"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region  = "ap-southeast-1"
  profile = "default"
}