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

# -----------------------------------------------------------------------------
# IAM User for GitHub Actions CI/CD
# -----------------------------------------------------------------------------
resource "aws_iam_user" "github_actions" {
  name = "github-actions-ci"
  path = "/ci/"

  tags = {
    Name    = "github-actions-ci"
    Purpose = "GitHub Actions CI/CD check for Terraform"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# IAM Policy — Scoped permissions for Terraform plan operations
#
# This policy allows:
# - Read-only access to most resources (for terraform plan)
# - Full access to the specific resources this project manages
# - Access to the S3 backend and DynamoDB lock table
# -----------------------------------------------------------------------------
resource "aws_iam_policy" "github_actions_terraform" {
  name        = "github-actions-terraform-ci"
  description = "Permissions for GitHub Actions CI/CD to run Terraform init, validate, and plan"
  path        = "/ci/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # S3 backend access
      {
        Sid    = "TerraformStateAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::netum-matias-tfstate-sandbox",
          "arn:aws:s3:::netum-matias-tfstate-sandbox/*"
        ]
      },
      # DynamoDB state locking
      {
        Sid    = "TerraformStateLock"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "arn:aws:dynamodb:eu-north-1:452138317873:table/terraform-state-lock"
      },
      # EC2 read access (for terraform plan to query current state)
      {
        Sid    = "EC2ReadAccess"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:Get*"
        ]
        Resource = "*"
      },
      # EC2 write access (scoped to project-tagged resources)
      {
        Sid    = "EC2WriteAccess"
        Effect = "Allow"
        Action = [
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:StopInstances",
          "ec2:StartInstances",
          "ec2:AllocateAddress",
          "ec2:ReleaseAddress",
          "ec2:AssociateAddress",
          "ec2:DisassociateAddress",
          "ec2:ImportKeyPair",
          "ec2:DeleteKeyPair",
          "ec2:CreateSecurityGroupEgressRule",
          "ec2:CreateSecurityGroupIngressRule",
          "ec2:DeleteSecurityGroupEgressRule",
          "ec2:DeleteSecurityGroupIngressRule"
        ]
        Resource = "*"
      },
      # IAM access (for managing the EC2 SSM role and instance profile)
      {
        Sid    = "IAMAccess"
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:GetPolicy",
          "iam:GetInstanceProfile",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PassRole",
          "iam:TagRole",
          "iam:TagInstanceProfile"
        ]
        Resource = [
          "arn:aws:iam::452138317873:role/${var.project_name}-*",
          "arn:aws:iam::452138317873:instance-profile/${var.project_name}-*",
          "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
        ]
      },
      # STS for caller identity checks
      {
        Sid    = "STSAccess"
        Effect = "Allow"
        Action = [
          "sts:GetCallerIdentity"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name    = "github-actions-terraform-ci"
    Purpose = "GitHub Actions CI/CD"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# Attach the policy to the user
# -----------------------------------------------------------------------------
resource "aws_iam_user_policy_attachment" "github_actions_terraform" {
  user       = aws_iam_user.github_actions.name
  policy_arn = aws_iam_policy.github_actions_terraform.arn
}

# -----------------------------------------------------------------------------
# Access key for GitHub Actions secrets
# -----------------------------------------------------------------------------
resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}
