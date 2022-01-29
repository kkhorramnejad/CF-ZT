# A variable for extracting the internal IP address of the instance
output "internal_ip" {
  description = "Private IP address of GCP instance"
  value       = google_compute_instance.origin.network_interface.0.network_ip
  sensitive   = false
}

# A variable for extracting the external IP address of the instance
output "external_ip" {
  description = "Public IP address of GCP instance"
  value       = google_compute_instance.origin.network_interface.0.access_config.0.nat_ip
  sensitive   = false
}

output "ssh_address" {
  value = "ssh-tf.${var.cloudflare_zone}"
}
output "ssh_username" {
  value = var.unix_username
}

output "web_address" {
  value = "web-tf.${var.cloudflare_zone}"
}


# client side
output "SSH_Config" {
  value = <<-EOT
  # To add a proxy on the enduser machine you need to wrap the ssh using the command below: 
      cloudflared access ssh-config --hostname ssh-tf.ssh-tf.${var.cloudflare_zone} --short-lived-cert > ssh.tmp && sed '1,2d' ssh.tmp >> ~/.ssh/config && rm ssh.tmp

EOT
}

# server side
output "CF_Tunnel" {
  value = <<-EOT
  # To do administrative tasks on Cloudflare Tunnels you need to prove your identity by authentication against Cloudflare dashboard using one of the methods below: 
  # If you are curretnly logged in to the server that the Tunnel is running on the command below will download and move the cert.pem file to the right directory.
      cloudflared tunnel login
  
  # Alternatively you can also visit the link below authenticate and once populated move the cert.pem file to the /root/.cloudflared/ directory
      https://dash.cloudflare.com/argotunnel

EOT
}