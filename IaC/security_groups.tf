# -----------------------------------------------------------------------------
# Security Group — Regional Map 2024 Portfolio Server
# -----------------------------------------------------------------------------
resource "aws_security_group" "web" {
  name        = "${var.project_name}-server-sg"
  description = "Allow HTTP, HTTPS, and SSH traffic for the portfolio/regional-map-2024 server"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name    = "${var.project_name}-server-sg"
    Project = var.project_name
  }
}

# --- Ingress rules --------------------

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  description       = "Allow HTTP from anywhere"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"

  tags = { Name = "http" }
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.web.id
  description       = "Allow HTTPS from anywhere"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"

  tags = { Name = "https" }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  for_each = toset(var.allowed_ssh_cidrs)

  security_group_id = aws_security_group.web.id
  description       = "Allow SSH from ${each.value}"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = each.value

  tags = { Name = "ssh-${each.value}" }
}

# --- Egress rule -------------------------------------------------------------

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.web.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = { Name = "all-outbound" }
}
