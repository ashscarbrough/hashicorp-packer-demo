resource "null_resource" "packer_build" {
  triggers = {
    git_commit = var.git_commit_sha
  }

  provisioner "local-exec" {
    command = <<-EOT
      cd ${path.module}
      packer init builds/al2023-demo/
      packer build \
        -var-file=builds/al2023-demo/variables.pkrvars.hcl \
        builds/al2023-demo/
    EOT
  }
}