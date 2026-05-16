# sandbox-infra
The IaC for a Sandbox AWS account

Public Terraform templates and stuff like that to set up on a regional-map-2024 server on a sandbox account on AWS.

# Portfolio/Where-to-Live-2024 Server with Terraform

Provisions an Amazon Linux 2023 EC2 instance with Nginx, ready to host static websites and a lot more.

GitHub Actions has also been set up as the CI/CD solution and runs on every PR to main by checking the status of IaC first.

## What gets created

- **EC2 instance** (t3.small, AL2023) with Nginx auto-installed via user_data
- **Security group** allowing HTTP (80), HTTPS (443), and SSH (22)
- **Elastic IP** so the public IP survives stop/start cycles
- **IAM role + instance profile** for SSM Session Manager (connect without SSH keys)
- **20 GB gp3 encrypted root volume**

## Usage

```bash
# 1. Copy and customise variables
cp terraform.tfvars.example terraform.tfvars

# 2. Initialise Terraform
terraform init

# 3. Preview what will be created
terraform plan

# 4. Deploy
terraform apply

# 5. Connect via SSM (no SSH key needed)
aws ssm start-session --target <instance-id> --region eu-north-1

# 6. Deploy your site files to the instance
#    From the SSM session on the instance:
sudo dnf install -y nginx   # already done by user_data, but just in case
#    Your site files go in: /usr/share/nginx/html/

# 7. Tear down when done
terraform destroy
```

## Deploying your website files

Once the instance is running, connect via SSM and transfer your files.
The Nginx document root is `/usr/share/nginx/html/`.

## Security notes

- IMDSv2 is enforced (no legacy metadata endpoint)
- Root volume is encrypted
- SSH is open to 0.0.0.0/0 by default — lock it to your IP in terraform.tfvars
- SSM access means you can remove SSH ingress entirely if you prefer that