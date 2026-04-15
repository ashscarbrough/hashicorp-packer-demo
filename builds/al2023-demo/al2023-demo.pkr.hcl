packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1.3"
    }
  }
}

# TOP LEVEL - not inside build block
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

  # Install base packages needed for Ansible to connect
  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y python3 cloud-init",
        "sudo dnf install -y nginx",
        "sudo systemctl enable nginx",
        "sudo systemctl start nginx",
        "echo '<html><body><h1>Base image: ${data.amazon-ami.hc-al2023-base.id} | Version: 0.1</h1></body></html>' | sudo tee /usr/share/nginx/html/index.html",
        "sudo systemctl enable cloud-init"
    ]
  }
}