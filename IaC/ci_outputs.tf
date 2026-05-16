# -----------------------------------------------------------------------------
# GitHub Actions CI/CD credentials
# After terraform apply, copy these into GitHub repo secrets
# -----------------------------------------------------------------------------
output "github_actions_access_key_id" {
  description = "AWS Access Key ID for GitHub Actions — add as repo secret AWS_ACCESS_KEY_ID"
  value       = aws_iam_access_key.github_actions.id
}

output "github_actions_secret_access_key" {
  description = "AWS Secret Access Key for GitHub Actions — add as repo secret AWS_SECRET_ACCESS_KEY"
  value       = aws_iam_access_key.github_actions.secret
  sensitive   = true
}
