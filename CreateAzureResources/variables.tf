variable "subscription_id" {
  description = "Subscription Id"
  default = "616dc8cb-ad45-4037-8802-ed33477a2247"
}

variable "client_id" {
  description = "client id"
  default = "5588b8f2-0873-4606-a356-6e6942725644"
}

variable "client_secret" {
  description = "client secret"
  default = "2a49b5a0-6ecf-49ce-ba1d-8b4a36c26599"
}

variable "tenant_id" {
  description = "tenant id"
  default = "4b986592-0c7e-4958-aca8-9640597ef4e2"
}

variable "prefix" {
  description = "The prefix used for all resources in this example"
  default = "cicd"
}

variable "location" {
  description = "The Azure location where all resources in this example should be created"
  default = "East US"
}

variable "environment" {
  description = "The environment"
  default = "devops"
}

variable "key_path" {
  default = "/home/azureuser/.ssh/authorized_keys"
}

variable "ssh_keys" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5XiVtSZc63lf5HmYKoVuSsqLMhra9yM1K//pGsnCVrciUw9PAL26lewgvDW8fLxDGupCMlltUvEyKBgON6j2ft7ybobUWxeE3iCihALY0+QTevuKkzIxkl3Sy46UtnCt/beiJ6mNVt7WblUHOxzFizkUBbzDEEpgHwKjpP50ZqMu2Um/6wj8+uUfRzllQjg6la+Ssr44+j0c5LXUzlk0cOCAsUyRnGQO0pgh/l5jvDppmL5yDRNAYRQUVIz7TrW+vCFJI9p3CbwXTclHXq2AQ/ocNRDT5IQuwl5YcpQuxrDCEtaRRYMWovyXoXGFmeescyXFe3KajMpIPiU6RyMgP jaigandh@LNAR-5CG8430F5X"
}
