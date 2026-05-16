# -----------------------------------------------------------------------------
# EC2 Instance — Amazon Linux 2023 with Nginx
# -----------------------------------------------------------------------------
resource "aws_instance" "regional_map_server" {
  ami                    = "ami-063f61adbae382edf" # hardcoded AMI to avoid re-deployment every time there's a new AMI
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.regional_map_server.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm.name
  key_name               = aws_key_pair.regional_map_server.key_name

  # Nginx bootstrap — instance comes up ready to serve content
  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y nginx
    systemctl enable nginx
    systemctl start nginx

    # Create a placeholder index page
    cat > /usr/share/nginx/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
    <head><title>Regional Map 2024/Portfolio</title></head>
    <body>
      <h1>It works!</h1>
      <p>Nginx is running on Amazon Linux 2023. Replace this with your site.</p>
    </body>
    </html>
    HTML
  EOF

  user_data_replace_on_change = true

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true

    tags = {
      Name    = "${var.project_name}-root-volume"
      Project = var.project_name
    }
  }

  metadata_options {
    http_tokens   = "required" # IMDSv2 only, security best practice
    http_endpoint = "enabled"
  }

  # Lifecycle block here to ignore the most recent AMI changes and prevent unnecessary instance replacement
  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name    = "${var.project_name}-server"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# Elastic IP, Keeps the same public IP across stop/start cycles
# -----------------------------------------------------------------------------
resource "aws_eip" "regional_map_server" {
  instance = aws_instance.regional_map_server.id
  domain   = "vpc"

  tags = {
    Name    = "${var.project_name}-eip"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# PEM key pair setup as output
# -----------------------------------------------------------------------------

resource "tls_private_key" "regional_map_server" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "regional_map_server" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.regional_map_server.public_key_openssh

  tags = {
    Name    = "${var.project_name}-key"
    Project = var.project_name
  }
}

output "private_key_pem" {
  description = "Private key, save this to a .pem file preferably locally"
  value       = tls_private_key.regional_map_server.private_key_pem
  sensitive   = true
}