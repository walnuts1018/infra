# パスワード取得方法

```bash
kubectl get secret -n code-server -o jsonpath='{range .items[*]}{@.metadata.name}{"\n"}' | grep codebox- | while read secret; do password=$(kubectl get secret $secret -n code-server -o jsonpath='{.data.password}' | base64 -d); echo https://$secret.walnuts.dev, password: $password; done
```
