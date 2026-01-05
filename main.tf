terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.7.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.4"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7.1"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.5.0"
    }
  }
}


provider "aws" {
  default_tags {
    tags = {
      project = var.project-name
    }
  }
}

provider "null" {

}

provider "archive" {

}

terraform {
  backend "s3" {}
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

