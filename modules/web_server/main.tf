
#Security Group
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
    cidr_blocks = ["0.0.0.0/0"]
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


#EC2 Instance
resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = var.subnet_id

  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
#!/bin/bash

yum update -y
yum install -y httpd

systemctl start httpd
systemctl enable httpd

cat > /var/www/html/index.html << 'HTMLEOF'
${var.html_content}
HTMLEOF

EOF

  tags = {
    Name        = "web-server-${var.environment}"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}



