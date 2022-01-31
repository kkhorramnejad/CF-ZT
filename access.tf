# Allowing emails to access but only when using Cloudflare Gateway.
resource "cloudflare_access_group" "tf_access_group" {
  account_id = var.cloudflare_account_id
  name       = "tf_access_group"

  include {
    email = [var.cloudflare_email, var.email_list[0], var.email_list[1]]
  }
  # require {
  #   device_posture = ["Gateway"]
  # }
}

# Access application to apply zero trust policy over Web endpoint
resource "cloudflare_access_application" "web_app" {
  zone_id                   = var.cloudflare_zone_id
  name                      = "Access protection for web-tf.${var.cloudflare_zone}"
  domain                    = "web-tf.${var.cloudflare_zone}"
  allowed_idps              = [cloudflare_access_identity_provider.github_oauth.id]
  auto_redirect_to_identity = true
  session_duration          = "1h"
}

# Access policy that the above appplication uses. (i.e. who is allowed in)
resource "cloudflare_access_policy" "web_policy" {
  application_id = cloudflare_access_application.web_app.id
  zone_id        = var.cloudflare_zone_id
  name           = "Example Policy for web-tf.${var.cloudflare_zone}"
  precedence     = "1"
  decision       = "allow"

  include {
    group = [cloudflare_access_group.tf_access_group.id]
  }
}


# Access application to apply zero trust policy over SSH endpoint
resource "cloudflare_access_application" "ssh_app" {
  zone_id          = var.cloudflare_zone_id
  name             = "Access protection for ssh-tf.${var.cloudflare_zone}"
  domain           = "ssh-tf.${var.cloudflare_zone}"
  type             = "ssh"
  session_duration = "1h"
}

# Access policy that the above appplication uses. (i.e. who is allowed in)
resource "cloudflare_access_policy" "ssh_policy" {
  application_id = cloudflare_access_application.ssh_app.id
  zone_id        = var.cloudflare_zone_id
  name           = "Example Policy for ssh-tf.${var.cloudflare_zone}"
  precedence     = "1"
  decision       = "allow"

  include {
    group = [cloudflare_access_group.tf_access_group.id]
  }
}

# Create SSH short-lived certificate
resource "cloudflare_access_ca_certificate" "ssh_short_lived" {
  zone_id        = var.cloudflare_zone_id
  application_id = cloudflare_access_application.ssh_app.id
}
