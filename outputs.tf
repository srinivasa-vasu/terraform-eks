output "region" {
  description = "AWS region"
  value       = var.region
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.oidcp.arn
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = data.aws_eks_cluster.cluster.name
}

output "cluster_id" {
  description = "EKS cluster ID."
  value       = data.aws_eks_cluster.cluster.id
}

output "endpoint" {
  description = "Endpoint for EKS control plane."
  value       = data.aws_eks_cluster.cluster.endpoint
}

output "ca-data" {
  value = data.aws_eks_cluster.cluster.certificate_authority[0].data
}

output "kubeconfig" {
  value = local.kubeconfig
}
