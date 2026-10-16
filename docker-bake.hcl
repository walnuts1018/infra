# Build definition for self-built images.
#
# Adding a new image is two steps:
#   1. Add images/<name>/Dockerfile
#   2. Add "<name>" to IMAGES below
#
# Bake's native matrix expands one target per image, so the target name,
# directory name, and image name stay identical with no extra bookkeeping.

variable "IMAGES" {
  default = [
    "actions-runner",
  ]
}

target "image" {
  matrix = {
    image = IMAGES
  }

  name       = image
  context    = "images/${image}"
  dockerfile = "Dockerfile"

  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}

group "default" {
  targets = ["image"]
}
