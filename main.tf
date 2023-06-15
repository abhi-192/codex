provider "aws" {
  region     = var.aws_region

  default_tags {
    tags = {
      codex-infra = "IaaC for provisioning aws resources for codeX"
    }
  }

}