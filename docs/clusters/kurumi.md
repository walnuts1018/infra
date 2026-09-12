# kurumi

`kurumi` は、管理クラスタ `berry` の Cluster API (CAPI) と Tart provider によって管理されるメインのワークロードクラスタです。

クラスタの構築や運用は、Git、berry 上の Argo CD、CAPI、Tart、Talos、CAPI addon、Argo CD Agent による GitOps で自動収束します。そのため、クラスタに対して直接手動でリソースを投入する必要はありません。

## クラスタ構成

- **ノード構成**: Control Plane 3台（`cake`, `hotate`, `lemon`）、Worker 1台（`rusk`）。
- **ホスト管理**: MACアドレス、管理用IP、ホストラベル、WoL / Redfish 設定などは [`k8s/clusters/kurumi/tart-hosts.jsonnet`](../../k8s/clusters/kurumi/tart-hosts.jsonnet) で定義。
- **クラスタ設定**: Kubernetes / Talos のバージョン、Pod / Service CIDR は [`k8s/clusters/kurumi/cluster.json5`](../../k8s/clusters/kurumi/cluster.json5) で管理。
- **API エンドポイント**: `192.168.4.11:6443`（Talos の Fabric BGP により Control Plane 3台から広報）。
- **ストレージ構成**:
  - 各ノードのディスク selector、WWID、TopoLVM、Longhorn 用 extension 設定は [`k8s/clusters/kurumi/_patches/`](../../k8s/clusters/kurumi/_patches/) および各 Tart 定義ファイルで管理。
- **共通コンポーネント**:
  - Cilium、Argo CD Spoke / Agent、1Password root 認証情報は、[`k8s/clusters/kurumi/argocd-agent-bootstrap.jsonnet`](../../k8s/clusters/kurumi/argocd-agent-bootstrap.jsonnet) 経由で自動配布されます。

## 物理要件・事前準備

各物理マシンの事前準備として以下を設定します。

- **`cake`, `hotate`**: Wake-on-LAN (WoL) による電源投入が可能な状態にしておく。
- **`lemon`**: 初回登録（enrollment）前に、BIOS で PXE / Network Boot を有効化し、ブート順序（Boot Order）に追加しておく。
- **`rusk`**: iLO (Redfish) の初期設定、PXE ブート設定、電源管理設定、および対象ディスクの物理接続を完了させておく。

初期設定完了後の電源投入、Talos のインストール、CNI、Agent、各種ワークロードのデプロイは、すべて CAPI と GitOps が自動で行います。

## 動作確認

`berry` 上で CAPI リソースが `Ready` になり、Argo CD の kurumi 向け Application が `Synced` かつ `Healthy` になっていれば正常に起動・連携されています。

```bash
kubectl --context berry -n kurumi get cluster,tartcluster,tartcontrolplane,machine,machinedeployment
kubectl --context berry -n argocd get applications -l argocd-agent=true
```

詳しい Agent の稼働状態確認や証明書の更新手順、トラブルシューティングについては [Argo CD Agent運用](../operations/argocd-agent.md) を参照してください。
