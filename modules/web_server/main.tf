# Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-sg-${var.environment}"
  description = "Web security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
    description = "SSH"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "web-sg-${var.environment}"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami                  = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = var.subnet_id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd awscli
 
    systemctl start httpd
    systemctl enable httpd
 
    aws s3 cp ${var.html_s3_uri} /var/www/html/index.html
 
    systemctl restart httpd
  EOF

  user_data_replace_on_change = true

  tags = {
    Name        = "web-server-${var.environment}"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}