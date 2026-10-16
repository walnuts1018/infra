# Build definition for self-built images.
#
# Adding a new image is two steps:
#   1. Add images/<name>/Dockerfile
#   2. Add "<name>" to group "default" and a matching target below
#
# Image name == directory name == Bake target name, so no duplicated
# name/context/path bookkeeping is needed.

variable "REGISTRY" {
  default = "ghcr.io"
}

variable "NAMESPACE" {
  default = "walnuts1018/infra"
}

group "default" {
  targets = ["actions-runner"]
}

// Shared settings for all self-built images.
target "_common" {
  platforms = ["linux/amd64", "linux/arm64"]
}

target "actions-runner" {
  inherits = ["_common"]
  context    = "images/actions-runner"
  dockerfile = "Dockerfile"
}
