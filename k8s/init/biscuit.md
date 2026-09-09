# biscuit初期構成

## 構成

`biscuit`はTalos上のCAPI管理クラスターとして`berry`から構築する。ノードはcontrol plane兼workerの1台構成で、Kubernetes APIは`192.168.0.15:6443`、Talos APIは`192.168.0.15`を使用する。

ディスク構成は240GB SSDをTalosのシステム領域とswapに使用し、1TBディスクを`hdd`ボリュームグループとしてTopoLVMに割り当てる。CNI、kube-proxy、TopoLVM、SeaweedFS、Cilium Gateway APIはGitOps管理とする。

## CAPI構築

`berry`のArgo CDから`k8s/clusters/biscuit`を適用する。TartHostの割り当て後にTalosのbootstrapが完了し、`biscuit`クラスターのAPIが到達可能になったことを確認する。

## Argo CD Agent

`biscuit`のSpokeとAgentの導入、Principalへの登録は[argocd-agent.md](argocd-agent.md)の`biscuit`手順を実行する。従来の`argocd cluster add`は使用しない。

登録後は`k8s/_argocd/applications/biscuit`のApplicationSetが、Cilium、TopoLVM、SeaweedFS、証明書、External SecretsをAgent経由で`biscuit`へ適用する。

## 1Password Connect

`onepassword-connect`は`biscuit`上で動作するため、Argo CD同期前に`onepassword` namespaceへ接続用Secretを作成する。

```bash
kubectl create namespace onepassword --context biscuit
kubectl create secret generic op-credentials -n onepassword --context biscuit \
  --from-literal=1password-credentials.json="$(op read 'op://kurumi/k8s Credentials File/1password-credentials.json')"
kubectl create secret generic onepassword-token -n onepassword --context biscuit \
  --from-literal=token="$(op read 'op://kurumi/pcookjymtl2zwyozhofaco5yhy/credential')"
```

## Argo CD

Argo CDのbase Applicationは`k8s/_argocd/applications`を再帰的に読み込み、`biscuit` ApplicationSetを作成する。同期後、`seaweedfs-biscuit.local.walnuts.dev`が`192.168.16.159`を指し、SeaweedFS S3 gatewayがバックアップ用エンドポイントとして公開される。

## OIDCログイン

必要に応じて、`kurumi`のCA証明書を`biscuit`へ配置して信頼ストアを更新する。

```bash
scp cake:/etc/kubernetes/pki/ca.crt biscuit:/usr/local/share/ca-certificates/kurumi.crt
sudo update-ca-certificates
```
