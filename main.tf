resource "null_resource" "packer_build" {
  triggers = {
    git_commit = var.git_commit_sha
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Install Packer
      wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
      apt-get update -y && apt-get install -y packer

      # Run Packer build
      cd ${path.module}
      packer init builds/al2023-demo/
      packer build \
        -var-file=builds/al2023-demo/variables.pkrvars.hcl \
        builds/al2023-demo/
    EOT

    interpreter = ["/bin/bash", "-c"]
  }
}