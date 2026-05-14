output "instance_id" {
  description = "EC2 instance ID (use with SSM: aws ssm start-session --target <id>)"
  value       = aws_instance.web.id
}

output "elastic_ip" {
  description = "Public Elastic IP address, put this in your browser to see the website"
  value       = aws_eip.web.public_ip
}

output "ssm_connect_command" {
  description = "Ready-to-paste SSM connect command"
  value       = "aws ssm start-session --target ${aws_instance.web.id} --region ${var.aws_region}"
}

output "ami_id" {
  description = "AMI used for the instance"
  value       = data.aws_ami.al2023.id
}
