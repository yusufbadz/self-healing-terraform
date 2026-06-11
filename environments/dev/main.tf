locals {
  common_tags = {
    Project     = "self-healing-terraform"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
    CostCenter  = "CS-PROJECT-2024"
    Repository  = "github.com/yusufbadz/self-healing-terraform"
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_s3_object" "index_html" {
  bucket       = "self-healing-tf-state"
  key          = "website/index.html"
  source       = "${path.module}/../../app/index.html"
  content_type = "text/html"

  etag = filemd5("${path.module}/../../app/index.html")
}

module "web_server" {
  source = "../../modules/web_server"

  ami_id        = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  environment   = var.environment
  owner         = var.owner
  vpc_id        = data.aws_vpc.default.id
  subnet_id     = data.aws_subnets.default.ids[0]

  html_s3_uri       = "s3://${aws_s3_object.index_html.bucket}/${aws_s3_object.index_html.key}"
  allowed_ssh_cidrs = var.allowed_ssh_cidrs

  depends_on = [
    aws_s3_object.index_html
  ]
}
 