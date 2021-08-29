# Deploy a Windows Instance on AWS with Terraform

This repository aims to install a `Microsoft Windows Server 2019 Base` instance by using the HashiCorp Terraform.

- [Deploy a Windows Instance on AWS with Terraform](#deploy-a-windows-instance-on-aws-with-terraform)
  - [1. AWS profile](#1-aws-profile)
  - [2. Set the Windows Username and Password](#2-set-the-windows-username-and-password)
  - [3. Run terraform](#3-run-terraform)
  - [4. Get the IP or FQDN output](#4-get-the-ip-or-fqdn-output)
  - [5. Destroy](#5-destroy)

## 1. AWS profile

Check that you have an AWS profile in `~/.aws/credentials`. Select the profile that will be used and set it for terraform:

```shell
export TF_VAR_AWS_PROFILE="default"
```

## 2. Set the Windows Username and Password

```shell
export TF_VAR_INSTANCE_USERNAME="admin"
export TF_VAR_INSTANCE_PASSWORD="Define_a_sup3R_S3cret_P@ssW0rd"
```

## 3. Run terraform


```shell
terraform init
terraform plan -out deploy_file
terraform apply deploy_file
```

## 4. Get the IP or FQDN output

Use an RDP client to connect to the IP or FQDN obtained from the output.

## 5. Destroy

If you wish to destroy all the created resources, run the following command:

```shell
terraform destroy
```

Type `yes` and hit `ENTER` if you really want to wipe all the created resources.