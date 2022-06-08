provider "aws" {
  region                   = var.region
  shared_credentials_files = [var.credentials]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

data "aws_vpc" "vpc" {
  # id = var.vpc
  filter {
    name   = "tag:Name"
    values = [var.vpc]
  }
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

data "aws_availability_zones" "zones" {
  state = "available"
}

data "aws_security_group" "sg" {
  filter {
    name   = "tag:Name"
    values = [var.security-group]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

}

data "aws_iam_role" "capa-cp-iam" {
  name = var.cp-service-role
}

data "aws_iam_role" "capa-wk-iam" {
  name = var.wk-service-role
}

data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.capa-cp.id
}

data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidcp.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:ybdp:ybdp"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidcp.arn]
      type        = "Federated"
    }
  }
}

data "tls_certificate" "cert" {
  url = data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

data "aws_iam_policy" "yb-access-policy" {
  name = var.yb-iam-policy
  tags = {
    kind = "policy"
  }
}

resource "aws_eks_cluster" "capa-cp" {
  name     = var.identifier
  role_arn = data.aws_iam_role.capa-cp-iam.arn

  vpc_config {
    subnet_ids             = toset(data.aws_subnets.subnets.ids)
    security_group_ids     = data.aws_security_group.sg[*].id
    endpoint_public_access = true
    # endpoint_private_access = true
  }

}

resource "aws_eks_node_group" "capa-wk" {
  cluster_name    = aws_eks_cluster.capa-cp.name
  node_group_name = "${var.identifier}-wk"
  node_role_arn   = data.aws_iam_role.capa-wk-iam.arn
  subnet_ids      = toset(data.aws_subnets.subnets.ids)
  instance_types  = [var.instance-type]
  disk_size       = var.disk-size

  scaling_config {
    desired_size = var.desired-size
    max_size     = var.max-size
    min_size     = var.min-size
  }

  update_config {
    max_unavailable = 1
  }
}

resource "aws_iam_openid_connect_provider" "oidcp" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cert.certificates.0.sha1_fingerprint]
  url             = data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

resource "aws_iam_role" "capa-sa-iam" {
  name               = var.sa-assume-role
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role_policy.json
}

resource "aws_iam_policy_attachment" "yb-policy-attach" {
  name       = var.sa-assume-role
  roles      = [aws_iam_role.capa-sa-iam.name]
  policy_arn = data.aws_iam_policy.yb-access-policy.arn
}

locals {
  kubeconfig = <<KUBECONFIG

apiVersion: v1
clusters:
- cluster:
    server: ${data.aws_eks_cluster.cluster.endpoint}
    certificate-authority-data: ${data.aws_eks_cluster.cluster.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${data.aws_eks_cluster.cluster.name}"
KUBECONFIG
}
