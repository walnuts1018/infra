# biscuit初期構成

## 構成

`biscuit`はTalos上のCAPI管理クラスターとして`berry`から構築する。ノードはcontrol plane兼workerの1台構成で、Kubernetes APIは`192.168.0.15:6443`、Talos APIは`192.168.0.15`を使用する。

ディスク構成は240GB SSDをTalosのシステム領域とswapに使用し、1TBディスクを`hdd`ボリュームグループとしてTopoLVMに割り当てる。CNI、kube-proxy replacementを含むCilium、TopoLVM、SeaweedFS、Cilium Gateway APIはGitOps管理とする。

## CAPI構築

`berry`のArgo CDから`k8s/clusters/biscuit`を適用する。TartHostの割り当て後にTalosのbootstrapが完了し、`biscuit`クラスターのAPIが到達可能になったことを確認する。

## Terraform bootstrap

fresh installではTerraformの1Passwordへの書き込み完了後にExternal Secrets OperatorがSecretを作成し、SeaweedFSがS3 APIをreadiness状態にするまで待つ必要がある。最初にcredentialを含むTerraform applyを完了し、biscuit上で対象Secret、SeaweedFSのreadiness、S3 APIを確認してから、SeaweedFSのbucketを含む残りのTerraform applyを実行する。同一apply内の`depends_on`だけではこのKubernetes内の非同期処理を待機できない。

## Argo CD Agent

`biscuit`のArgo CD SpokeとAgentは、`k8s/clusters/biscuit`のClusterResourceSetとHelmChartProxyが自動導入する。通常の新規構築ではworkload clusterへ`helm install`したり、TLS Secretを手動作成したり、`argocd-agentctl agent create`を実行したりしない。

Gateway API CRDは`gateway-api-crds` Applicationがv1.6.1を導入する。Cilium bootstrapはGateway APIを無効にして起動し、CRD導入後にAgent経由の通常ApplicationがCiliumを最終値へ更新する。bootstrap Jobを手動で作成しない。

PrincipalのJWT signing keyが未作成の場合だけ、次のコマンドを一度実行する。

```bash
argocd-agentctl --principal-context berry --principal-namespace argocd jwt create-key
```

`argocd-agent-certs`が`argocd-agent-client-tls-biscuit`を発行し、ESOとClusterResourceSetがworkload clusterの`argocd-agent-client-tls`と`argocd-agent-ca`へ配送する。次のコマンドでPrincipalのself-registrationとAgentの状態を確認する。

```bash
kubectl --context berry -n argocd get secret cluster-biscuit
kubectl --context berry -n biscuit get helmchartproxy,clusterresourceset,externalsecret
kubectl --context biscuit -n argocd get secret argocd-agent-client-tls argocd-agent-ca
kubectl --context biscuit -n argocd get pods
```

証明書更新後はAgentがTLS Secretを起動時に読み込むため、次のコマンドで再起動する。

```bash
mise run argocd-agent:restart biscuit
```

登録後は`k8s/_argocd/applications/biscuit`の`argocd-spoke-biscuit`と`argocd-agent-biscuit`がbootstrapのHelmChartProxyを引き継ぎ、その後ApplicationSetがCilium、TopoLVM、SeaweedFS、証明書、External SecretsをAgent経由で`biscuit`へ適用する。

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

通常のNamespaceは`app.json5`の`namespace`をApplicationの配置先として`CreateNamespace=true`で作成する。`namespaces-biscuit`は通常のNamespace一覧を管理せず、CiliumのPSA設定が必要な`cilium-system`だけを明示manifestで管理する。`cilium-secrets`はCiliumのbiscuit向け設定で作成する。

## ハードウェア依存値

`k8s/clusters/biscuit/_patches/control-plane.yaml`のディスクセレクターは、`eclair`の240GB SSDと1TB HDDを誤認識しないためにサイズとWWIDを固定している。ディスク交換やホスト変更の前には`talosctl get disks --nodes 192.168.0.15 -o yaml`で現在の`size`と`wwid`を確認し、対象ディスク以外を選択しないことを確認してからパッチを更新する。

`k8s/clusters/biscuit/tart-control-plane.jsonnet`の`schematicID`は、`cluster.json5`の`talosVersion`に対応するTalos Factoryの生成済みSchematic IDを固定している。Talosのバージョンを変更するときは、同じExtension構成でTalos FactoryからSchematic IDを再生成し、バージョンとIDの組み合わせを更新したうえで、既存ノードのディスクセレクターとbootstrap結果を確認する。TartHostとMACアドレスの対応は`k8s/clusters/biscuit/tart-hosts.jsonnet`で管理する。

## 可用性と復旧目標

`biscuit`はcontrol plane兼workerが1台で、SeaweedFSも`replicas: 1`のため、ノード再起動中はSeaweedFSと同じバックアップ経路を利用するサービスが停止する。TopoLVMのStorageClassは`Retain`だが、これはPVCやPVの削除を防ぐだけであり、ノード障害やディスク故障からデータを復元できることを意味しない。

SeaweedFSのcurrent objectの保持はアプリケーション側のretention設定で管理する。noncurrent versionは30日、未完了multipart uploadは7日で削除する。B2はcurrent objectを自動hideせず、置き換えやrelay/B2 prefixのpurgeでhiddenになったversionを30日保持する。そのためsource bucket消失からの実効的なrecoverabilityは、prefix purgeまでの30日とB2のlifecycleを合わせて最大約60日になる。`skip-backup`は`skip-backup=true`のtagだけを認識し、bucketを存在中として扱うため、その実行でコピーを行わず、既存のrelayとB2のprefixも削除しない。source bucketの消失はmanifestで30日追跡し、経過後にrelayとB2のprefixを削除する。

| 対象 | RPOの目安 | RTOの扱い |
| --- | --- | --- |
| Kubernetesリソース | Veleroの最終成功バックアップから最大24時間 | Talosホスト復旧後にSeaweedFSのreadiness、S3アクセス、Veleroのテスト復元を確認する。実測値は未確定 |
| PostgreSQL | 最終成功したWALアーカイブまで。フルバックアップのスケジュールはクラスターごとに異なる | CloudNativePGのObjectStoreからの復元を実施して実測する。SeaweedFS停止中は新規WALアーカイブも停止する |
| SeaweedFSのバックアップデータ | 外部コピーの最終成功時点まで。単一ノードのローカルPVだけではRPOを保証しない | ホスト、Talos、TopoLVM、SeaweedFSの順に復旧し、S3バケットの整合性を確認する。実測値は未確定 |

復旧時は既存のRetain済みPVとLVを削除せず、`SeaweedFS`の`/readyz`、対象バケットへの読み書き、VeleroとCloudNativePGのテスト復元を順に確認する。RTOを運用目標として掲げる前に、ディスク交換を含む復旧訓練で所要時間とバックアップの復元可能性を記録する。

## OIDCログイン

`kurumi`のCA証明書をTalosホストへコピーしたり、ホストの信頼ストアを変更したりせず、Kubernetesが作成する`kube-root-ca.crt`を検証用のCAとして取得する。

```bash
kubectl --context kurumi -n default get configmap kube-root-ca.crt \
  -o jsonpath='{.data.ca\.crt}' > /tmp/kurumi-ca.crt
curl --cacert /tmp/kurumi-ca.crt \
  https://192.168.4.11:6443/.well-known/openid-configuration
```
