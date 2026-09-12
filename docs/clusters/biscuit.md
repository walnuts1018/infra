# biscuit

`biscuit` は、管理クラスタ `berry` の Cluster API (CAPI) と Tart provider によって管理されるワークロードクラスタです。

クラスタの構築や運用は、Git、berry 上の Argo CD、CAPI、Tart、Talos、CAPI addon、Argo CD Agent による GitOps で自動収束します。そのため、クラスタに対して直接手動でリソースを投入する必要はありません。

## クラスタ構成

- **ノード構成**: `eclair` 1台のシングルノード構成（Control Plane兼Worker）。
- **ホスト管理**: MACアドレス、管理用IP、Intel AMT/MEBx エンドポイント、ホストラベルなどは [`k8s/clusters/biscuit/tart-hosts.jsonnet`](../../k8s/clusters/biscuit/tart-hosts.jsonnet) で定義。
- **クラスタ設定**: Kubernetes / Talos のバージョンやノード数は [`k8s/clusters/biscuit/cluster.json5`](../../k8s/clusters/biscuit/cluster.json5) で管理。
- **API エンドポイント**: `192.168.0.15:6443`
- **ストレージ構成**:
  - 240GB SSD: Talos のシステム領域および swap
  - 1TB HDD: LVM（`hdd` ボリュームグループ）および TopoLVM
  - ディスクの selector や WWID 定義: [`k8s/clusters/biscuit/_patches/control-plane.yaml`](../../k8s/clusters/biscuit/_patches/control-plane.yaml)
- **SeaweedFS**:
  - TopoLVM 上の単一 Pod 構成（マニフェスト: [`k8s/apps/seaweedfs-biscuit`](../../k8s/apps/seaweedfs-biscuit)）。
  - バケット作成やライフサイクル設定などの初期化後タスクは Terraform で管理します。詳細は [Terraform運用](../operations/terraform.md) を参照してください。
- **共通コンポーネント**:
  - Cilium、Argo CD Spoke / Agent、1Password root 認証情報は、[`k8s/clusters/biscuit/argocd-agent-bootstrap.jsonnet`](../../k8s/clusters/biscuit/argocd-agent-bootstrap.jsonnet) 経由で kurumi と共通の構成で自動配布されます。

## 物理要件・事前準備

物理マシン `eclair` の事前準備として以下を設定します。

- **BIOS**: PXE ブートを有効化し、ブート順序（Boot Order）を設定する。
- **Intel AMT / MEBx**: 初期ユーザー・パスワードを設定し、Network Boot を有効化する。
- **ストレージ配線**: SSD と HDD を所定のポートへ接続する（※ドライブ換装時はサイズや WWID を確認し、マニフェスト側の selector を更新してください）。

初期設定完了後の電源投入、Talos のインストール、CNI、TopoLVM、SeaweedFS、Agent、各種ワークロードのデプロイは、すべて CAPI と GitOps が自動で行います。

## 動作確認

`berry` 上で CAPI リソースが `Ready` になり、Argo CD の biscuit 向け Application が `Synced` かつ `Healthy` になっていれば正常に起動・連携されています。

```bash
kubectl --context berry -n biscuit get cluster,tartcluster,tartcontrolplane,machine,machinedeployment
kubectl --context berry -n argocd get applications -l argocd-agent=true
```

詳しい Agent の稼働状態確認や証明書の更新手順、トラブルシューティングについては [Argo CD Agent運用](../operations/argocd-agent.md) を参照してください。

