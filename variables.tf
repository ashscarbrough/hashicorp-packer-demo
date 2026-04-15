variable "git_commit_sha" {
  description = "Git commit SHA — forces null_resource to re-run on every push"
  type        = string
}