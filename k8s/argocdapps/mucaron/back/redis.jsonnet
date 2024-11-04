{
  "apiVersion": "redis.redis.opstreelabs.in/v1beta2",
  "kind": "Redis",
  "metadata": {
    "name": "mucaron-redis",
    "labels": {
      "app.kubernetes.io/name": "mucaron-redis"
    }
  },
  "spec": {
    "kubernetesConfig": {
      "image": "quay.io/opstree/redis:v7.0.12",
      "imagePullPolicy": "IfNotPresent",
      "redisSecret": {
        "name": "mucaron-backend",
        "key": "redis_password"
      }
    },
    "storage": {
      "volumeClaimTemplate": {
        "spec": {
          "accessModes": [
            "ReadWriteOnce"
          ],
          "resources": {
            "requests": {
              "storage": "1Gi"
            }
          }
        }
      }
    },
    "podSecurityContext": {
      "fsGroup": 1000,
      "runAsUser": 1000
    }
  }
}
