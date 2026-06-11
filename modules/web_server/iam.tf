# IAM Role — allows EC2 to assume it
resource "aws_iam_role" "ec2_role" {
  name = "web-server-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = {
    Name        = "web-server-role-${var.environment}"
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

# Attach CloudWatch Logs (write application logs)
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# Attach SSM (connect to instance without needing SSH keys)
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile wraps the role so EC2 can use it
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "web-server-profile-${var.environment}"
  role = aws_iam_role.ec2_role.name
}