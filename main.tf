resource "null_resource" "packer_build" {
  triggers = {
    git_commit    = var.git_commit_sha
    template_hash = filemd5("${path.module}/builds/al2023-demo/al2023-demo.pkr.hcl")
    vars_hash     = filemd5("${path.module}/builds/al2023-demo/variables.pkrvars.hcl")
  }

provisioner "local-exec" {
  command = <<-EOT
    set -e

    PACKER_VERSION="1.15.1"
    wget -q -O /tmp/packer.zip "https://releases.hashicorp.com/packer/$${PACKER_VERSION}/packer_$${PACKER_VERSION}_linux_amd64.zip"
    unzip -o /tmp/packer.zip -d /tmp/
    chmod +x /tmp/packer

    export PACKER_PLUGIN_PATH="/tmp/packer-plugins"
    mkdir -p /tmp/packer-plugins

    cd ${path.module}
    /tmp/packer init builds/al2023-demo/
    /tmp/packer build \
      -var-file=builds/al2023-demo/variables.pkrvars.hcl \
      builds/al2023-demo/
  EOT

  interpreter = ["/bin/bash", "-c"]
  }
}