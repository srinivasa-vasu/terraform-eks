# Provision an EKS Cluster

Terraform configuration files to provision an EKS cluster on AWS.

## Initialization
* Clone this repo to the local workstation

```
$ git clone https://github.com/srinivasa-vasu/terraform-eks.git
```

* Change directory to the cloned repo

```
$ cd terraform-eks
```

* Create `terraform.tfvars` file with the needed data populated (or update `sample.terraform.tfvars` file appropriately and rename it to `terraform.tfvars`)


## Usage

* Run terraform init to initialize the modules dependencies

```
$ terraform init
```

* Generate the terraform plan to understand the changes

```
$ terraform plan -out=plan
```

* Run the following to apply the changes

```
$ terraform apply plan
```

* Run the following the fetch the values from the terraform run

```
$ terraform output <output_variable>
```

* To destroy the provisioned resources,

```
$ terraform destroy
```

## Managed Resources

This terraform-module manages the following resources

- control plane
- worker nodes
- oidc
- iam-policy