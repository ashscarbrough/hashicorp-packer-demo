packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1.3"
    }
  }
}

hcp_packer_registry {
  bucket_name = var.hcp_bucket_name
  description = "AL2023 demo image for AAP+TFE demo"

  bucket_labels = {
    "os"          = "amazon-linux-2023"
    "environment" = "dev"
    "demo"        = "aap-tfe-demo"
  }

  build_labels = {
    "build-time" = "{{timestamp}}"
  }
}

data "amazon-ami" "hc-al2023-base" {
  region = var.aws_region
  filters = {
    name  = "${var.ec2_instance_ami_name}-*"
    state = "available"
  }
  most_recent = true
  owners      = ["888995627335"]
}

source "amazon-ebs" "al2023_demo" {
  region          = var.aws_region
  instance_type   = var.instance_type
  source_ami      = data.amazon-ami.hc-al2023-base.id
  ssh_username    = "ec2-user"
  ami_name        = "demo-al2023-{{timestamp}}"
  ami_description = "Demo AL2023 - HashiCorp compliant image built by Packer"

  # Tags on the temporary instance used for building the image
  run_tags = {
    Name        = "packer-temporary-image-build-al2023"
    Purpose     = "packer-build-temporary"
    ManagedBy   = "packer"
    AutoDelete  = "true"
  }

  # Tags to apply to the resulting AMI and any associated resources (like snapshots)
  tags = {
    Name          = "demo-al2023"
    BuildDate     = "{{timestamp}}"
    ManagedBy     = "packer"
    AnsibleManaged = "true"
  }
}

build {
  name    = "al2023-demo"
  sources = ["source.amazon-ebs.al2023_demo"]

  provisioner "shell" {
    inline = [
      # Base packages
      "sudo dnf update -y",
      "sudo dnf install -y python3 cloud-init nginx",

      # Create nginx config with two locations:
      # / → version page (baked at build time)
      # /status → runtime status page (written by Ansible post-deploy)
      "sudo tee /etc/nginx/conf.d/demo.conf > /dev/null <<'NGINXCONF'",
      "server {",
      "    listen 80;",
      "    root /usr/share/nginx/html;",
      "    location / { try_files $uri $uri/ =404; }",
      "    location /status { alias /var/www/status/; try_files $uri $uri/ =404; }",
      "}",
      "NGINXCONF",

      # Bake the version page at image build time
      "sudo mkdir -p /usr/share/nginx/html",
      "sudo tee /usr/share/nginx/html/index.html > /dev/null <<HTMLEOF",
      "<!DOCTYPE html>",
      "<html>",
      "<head><title>AAP + Terraform + Packer Demo</title>",
      "<style>body{font-family:sans-serif;max-width:800px;margin:40px auto;padding:0 20px;}",
      ".badge{display:inline-block;padding:4px 12px;border-radius:4px;font-size:14px;}",
      ".packer{background:#5C4EE5;color:white;}",
      ".pending{background:#f0ad4e;color:white;}",
      "h1{color:#5C4EE5;}</style></head>",
      "<body>",
      "<h1>HashiCorp + Red Hat Better Together</h1>",
      "<h2>Image Details</h2>",
      "<p><strong>App version:</strong> ${var.app_version}</p>",
      "<p><strong>Base AMI:</strong> ${data.amazon-ami.hc-al2023-base.id}</p>",
      "<p><strong>Built by:</strong> <span class='badge packer'>HCP Packer</span></p>",
      "<h2>Runtime Configuration</h2>",
      "<p><span class='badge pending'>Pending AAP configuration...</span></p>",
      "<p>Visit <a href='/status'>/status</a> for live runtime details after Ansible configures this instance.</p>",
      "</body></html>",
      "HTMLEOF",

      # Create status directory for Ansible to write into
      "sudo mkdir -p /var/www/status",
      "sudo chmod 755 /var/www/status",

      # Enable services
      "sudo systemctl enable nginx",
      "sudo systemctl enable cloud-init"
    ]
  }
}