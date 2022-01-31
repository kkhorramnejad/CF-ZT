terraform {
  cloud {
    organization = var.tfc_org
    workspaces {
      tags = ["var.tfc_workspaces_tags[0]"]
    }
  }
}

data "google_compute_image" "debian_image" {
  family  = "debian-9"
  project = "debian-cloud"
}

# GCP Instance resource 
resource "google_compute_instance" "origin" {
  name         = "tf-instance"
  machine_type = var.machine_type
  zone         = var.zone
  // Your tags may differ. This one instructs the networking to not allow access to port 22
  tags = ["no-direct-ssh"]
  labels = {
    owner = var.gcp_label_owner,
    team  = var.gcp_label_team,
  }
  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian_image.self_link
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }
  # // Optional config to make instance ephemeral 
  # scheduling {
  #   preemptible       = true
  #   automatic_restart = false
  # }
  // This is where we configure the server (aka instance). Variables like web_zone take a terraform variable and provide it to the server so that it can use them as a local variable
  metadata_startup_script = templatefile("./instance.tpl",
    {
      web_zone    = var.cloudflare_zone,
      account     = var.cloudflare_account_id,
      tunnel_id   = cloudflare_argo_tunnel.auto_tunnel.id,
      tunnel_name = cloudflare_argo_tunnel.auto_tunnel.name,
      secret      = random_id.tunnel_secret.b64_std
      ssh_ca_cert = cloudflare_access_ca_certificate.ssh_short_lived.public_key
      username    = var.unix_username
      password    = var.unix_password
  })
}

# DNS settings to CNAME to tunnel target for HTTP application
resource "cloudflare_record" "http_app" {
  zone_id = var.cloudflare_zone_id
  name    = "web-tf"
  #  name    = var.cloudflare_zone
  value   = "${cloudflare_argo_tunnel.auto_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}
# DNS settings to CNAME to tunnel target for SSH
resource "cloudflare_record" "ssh_app" {
  zone_id = var.cloudflare_zone_id
  name    = "ssh-tf"
  value   = "${cloudflare_argo_tunnel.auto_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}