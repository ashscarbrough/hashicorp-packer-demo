resource "null_resource" "packer_build" {
  triggers = {
    git_commit = var.git_commit_sha
  }

    provisioner "local-exec" {
    command = <<-EOT
        set -e

        # Download and install Packer binary directly
        PACKER_VERSION="1.15.0"
        wget -q -O /tmp/packer.zip "https://releases.hashicorp.com/packer/$${PACKER_VERSION}/packer_$${PACKER_VERSION}_linux_amd64.zip"
        unzip -o /tmp/packer.zip -d /tmp/
        chmod +x /tmp/packer
        export PATH="/tmp:$PATH"

        # Run Packer build
        cd ${path.module}
        /tmp/packer init builds/al2023-demo/
        /tmp/packer build \
        -var-file=builds/al2023-demo/variables.pkrvars.hcl \
        builds/al2023-demo/
    EOT

    interpreter = ["/bin/bash", "-c"]
    }
}