# -------------------------------------------------------
# TFVars, variable values for Terraform configuration
# -------------------------------------------------------

aws_region    = "eu-north-1"
instance_type = "t3.small"
project_name  = "regional-map-2024"

# Lock SSH down to your IP for security (find yours at https://checkip.amazonaws.com)
# Example: allowed_ssh_cidrs = ["203.0.113.42/32"]
allowed_ssh_cidrs = ["0.0.0.0/0"]
