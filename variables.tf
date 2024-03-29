variable "region" {
  description = "aws region to deploy the services to"
  default     = "ap-south-1"
  type        = string
}

variable "credentials" {
  description = "iam credentials"
  type        = string
}

variable "vpc" {
  description = "vpc region"
  type        = string
}

variable "identifier" {
  description = "run identifier"
  type        = string
}

variable "security-group" {
  description = "security group name"
  type        = string
}

variable "cp-service-role" {
  description = "control plane service account role"
  type        = string
}

variable "wk-service-role" {
  description = "node group service account role"
  type        = string
}

variable "sa-assume-role" {
  description = "service account assume role"
  type        = string
}

variable "yb-iam-policy" {
  description = "platform access policy"
  type        = string
}

variable "instance-type" {
  description = "node group instance type"
  type        = string
}

variable "disk-size" {
  description = "node group volume size"
  type        = string
}

variable "min-size" {
  description = "node group min size"
  type        = string
}

variable "max-size" {
  description = "node group max size"
  type        = string
}

variable "desired-size" {
  description = "node group desired size"
  type        = string
}

variable "addons" {
  type = list(object({
    name = string
    # version = string
  }))

  default = [
    {
      name = "kube-proxy"
    },
    {
      name = "vpc-cni"
    },
    {
      name = "coredns"
    },
    {
      name = "aws-ebs-csi-driver"
    }
  ]
}