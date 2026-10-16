# 新しいイメージは`images/<名前>/Dockerfile`の追加とIMAGESへの1行追加で登録する。
# ターゲット名、ディレクトリ名、イメージ名はmatrix展開により常に一致する.

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
