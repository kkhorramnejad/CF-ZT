#! /bin/bash
# Script to install Cloudflare Tunnel and Apache web server
# Apache configuration
# The OS is updated and docker is installed
sudo apt update -y && sudo apt upgrade -y
sudo apt install wget -y && sudo apt install apache2 -y
# This is a herefile that is used to customize the /var/www/html/index.html file.  
cat > /var/www/html/index.html << "EOF"
<html>
<body>
<h1>Hello world!</h1>
<p>This Apache Web app was build for a Cloudflare demo using Terraform!</p>
</body>
</html>
EOF
sudo systemctl start apache2

# cloudflared configuration
cd
# The package for this OS is retrieved 
wget https://github.com/cloudflare/cloudflared/releases/download/2021.8.0/cloudflared-linux-amd64
mv ./cloudflared-linux-amd64 /usr/local/bin/cloudflared
chmod a+x /usr/local/bin/cloudflared
cloudflared update
# A local user directory is first created before we can install the tunnel as a system service 
mkdir ~/.cloudflared
touch ~/.cloudflared/cert.json
touch ~/.cloudflared/config.yml
# Another herefile is used to dynamically populate the JSON credentials file 
cat > ~/.cloudflared/cert.json << "EOF"
{
    "AccountTag"   : "${account}",
    "TunnelID"     : "${tunnel_id}",
    "TunnelName"   : "${tunnel_name}",
    "TunnelSecret" : "${secret}"
}
EOF
# Same concept with the Ingress Rules the tunnel will use 
cat > ~/.cloudflared/config.yml << "EOF"
tunnel: ${tunnel_id}
credentials-file: /root/.cloudflared/cert.json
protocol: quic
warp-routing:
  enabled: true
#warp-routing is required if you are configuring private routing using WARP client
#originRequest:
     #noTLSVerify: true
#Uncomment the above two lines if your customer is using self-signed certificates in their origin server

ingress:
  - hostname: web-tf.${web_zone}
    service: http://localhost:80
  - hostname: ssh-tf.${web_zone}
    service: ssh://localhost:22
  - hostname: "*"
    path: "^/_healthcheck$"
    service: http_status:200
  - hostname: "*"
    service: hello-world

logfile: /var/log/cloudflared.log
#cloudflared to the origin trace
loglevel: trace
#cloudflared to cloudflare network trace
transport-loglevel: debug
EOF
# Now we install the tunnel as a systemd service 
sudo cloudflared service install
# Deleting ~/.cloudflared/config.yml sine we have it in /etc/cloudflared
sudo rm ~/.cloudflared/config.yml
# Now we can start the tunnel 
sudo systemctl start cloudflared

# Change SSH configuration to support browser based
sudo cat > /etc/ssh/ca.pub << "EOF"
${ssh_ca_cert}
EOF

sudo sed -i 's/#PubkeyAuthentication/PubkeyAuthentication/' /etc/ssh/sshd_config
sudo sed -i '$ a TrustedUserCAKeys /etc/ssh/ca.pub' /etc/ssh/sshd_config
sudo systemctl restart ssh

# Unix usernames must match the identity preceding the email domain. 
sudo useradd -p $(openssl passwd -1 ${password}) -s /bin/bash -d /home/${username}/ -m -G sudo ${username}
