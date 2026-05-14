output "instance_id" {
  description = "EC2 instance ID (use with SSM: aws ssm start-session --target <id>)"
  value       = aws_instance.regional_map_server.id
}

output "elastic_ip" {
  description = "Public Elastic IP address, put this in your browser to see the website"
  value       = aws_eip.regional_map_server.public_ip
}

output "ssm_connect_command" {
  description = "Ready-to-paste SSM connect command"
  value       = "aws ssm start-session --target ${aws_instance.regional_map_server.id} --region ${var.aws_region}"
}

output "ami_id" {
  description = "AMI used for the instance"
  value       = data.aws_ami.al2023.id
}
