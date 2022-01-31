# Providers
provider "cloudflare" {
  email      = var.cloudflare_email
  account_id = var.cloudflare_account_id
  api_key    = var.cloudflare_token
}
provider "google" {
  project = var.gcp_project_id
}

provider "random" {
}

# GCP variables
variable "gcp_project_id" {
  description = "Google Cloud Platform (GCP) Project ID."
  type        = string
}

variable "zone" {
  description = "GCP zone name."
  type        = string
}

variable "machine_type" {
  description = "GCP VM instance machine type."
  type        = string
}
variable "gcp_label_owner" {
  description = "Label the owner of a GCP object:"
  type        = string
}

variable "gcp_label_team" {
  description = "Label the team of a GCP object:"
  type        = string
}

variable "unix_username" {
  description = "Unix username must match the IdP for ssh to work with short-lived cert"
  type        = string
}

variable "unix_password" {
  description = "Password for the Unix user we need to add"
  type        = string
}
# Cloudflare Variables
variable "cloudflare_zone" {
  description = "The Cloudflare Zone to use."
  type        = string
}

variable "cloudflare_zone_id" {
  description = "The Cloudflare UUID for the Zone to use."
  type        = string
}

variable "cloudflare_account_id" {
  description = "The Cloudflare UUID for the Account the Zone lives in."
  type        = string
  sensitive   = true
}

variable "cloudflare_email" {
  description = "The Cloudflare user."
  type        = string
  sensitive   = true
}

variable "email_list" {
  description = "list of specific emails where you will be refferencing in rules"
  type        = list(string)
  sensitive   = true
}

variable "cloudflare_token" {
  description = "The Cloudflare user's API token."
  type        = string
  sensitive   = true

}

# Identity Prodiver Variables
variable "github_client_id" {
  description = "CF requiers client ID to set up athentication"
  type        = string
  sensitive   = true

}

variable "github_client_secret" {
  description = "CF requiers client secret to set up athentication"
  type        = string
  sensitive   = true

}

# Terraform Cloud Variables
variable "tfc_org" {
  description = "name of your organization in terraform cloud"
  type        = string
  sensitive   = true
}

variable "tfc_workspaces" {
  description = "name of your workspaces in terraform cloud"
  type        = list(string)
  sensitive   = true
}