# イメージの追加時は`images/<名前>/Dockerfile`を配置し、`IMAGES`に名前を追加する。

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
