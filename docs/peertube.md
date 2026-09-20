# PeerTube初回セットアップ

## 初回処理

```sh
kubectl -n peertube exec deploy/peertube -- \
  node dist/scripts/migrations/peertube-8.3.js
```

## 初期rootパスワード

```sh
secret_name="$(kubectl -n peertube get externalsecret peertube-secrets -o jsonpath='{.spec.target.name}')"
kubectl -n peertube get secret "${secret_name}" -o jsonpath='{.data.admin-password}' | base64 -d
```
