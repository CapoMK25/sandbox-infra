# -----------------------------------------------------------------------------
# IAM Role — Allows SSM Session Manager access (no SSH key needed)
# -----------------------------------------------------------------------------
resource "aws_iam_role" "ec2_ssm" {
  name = "${var.project_name}-al2023-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-al2023-ssm-role"
    Project = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "${var.project_name}-al2023-ssm-profile"
  role = aws_iam_role.ec2_ssm.name

  tags = {
    Name    = "${var.project_name}-al2023-ssm-profile"
    Project = var.project_name
  }
}
