output "ecr_repositories" {
  description = "ECR repositories per service"
  value = {
    for name, repo in aws_ecr_repository.service :
    name => {
      name = repo.name
      url  = repo.repository_url
    }
  }
}

output "ci_ecr_push_policy_arn" {
  description = "IAM policy ARN to attach to the CI IAM user/role for pushing images"
  value       = aws_iam_policy.ci_ecr_push.arn
}
