# kurumi

`kurumi`は、管理クラスタ`berry`のCluster API(CAPI)とTart providerによって管理されるメインのワークロードクラスタです。

クラスタの構築や運用は、Git、`berry`上のArgo CD、CAPI、Tart、Talos、CAPI addon、Argo CD AgentによるGitOpsで自動収束します。そのため、クラスタに対して直接手動でリソースを投入する必要はありません。

## クラスタ構成

- Control Plane 3台(`cake`、`hotate`、`lemon`)とWorker 1台(`rusk`)で構成します。
- TartHostのMACアドレス、管理用IP、ホストラベル、WoL/Redfish設定などは[`k8s/clusters/kurumi/tart-hosts.jsonnet`](../../k8s/clusters/kurumi/tart-hosts.jsonnet)で定義します。
- KubernetesやTalosのバージョン、Pod/Service CIDRは[`k8s/clusters/kurumi/cluster.json5`](../../k8s/clusters/kurumi/cluster.json5)で管理します。
- Kubernetes APIエンドポイントは`192.168.4.11:6443`で、TalosのFabric BGPによりControl Plane 3台から広報します。
- 各ノードのディスクselector、WWID、TopoLVM、Longhorn用extension設定は[`k8s/clusters/kurumi/_patches/`](../../k8s/clusters/kurumi/_patches/)および各Tart定義ファイルで管理します。
- Cilium、Argo CD Spoke/Agent、1Password root認証情報は、[`k8s/clusters/kurumi/argocd-agent-bootstrap.jsonnet`](../../k8s/clusters/kurumi/argocd-agent-bootstrap.jsonnet)経由で自動配布されます。

## 物理要件と事前準備

各物理マシンの事前準備として以下を設定します。

- `cake`および`hotate`はWake-on-LAN(WoL)による電源投入が可能な状態にしておきます。
- `lemon`は初回登録(enrollment)前にBIOSでPXE/Network Bootを有効化し、ブート順序(Boot Order)に追加しておきます。
- `rusk`はiLO(Redfish)の初期設定、PXEブート設定、電源管理設定、および対象ディスクの物理接続を完了させておきます。

初期設定完了後の電源投入、Talosのインストール、CNI、Agent、各種ワークロードのデプロイは、すべてCAPIとGitOpsが自動で行います。

## 動作確認

`berry`上でCAPIリソースが`Ready`になり、Argo CDのkurumi向けApplicationが`Synced`かつ`Healthy`になっていれば正常に起動・連携されています。

```bash
kubectl --context berry -n kurumi get cluster,tartcluster,tartcontrolplane,machine,machinedeployment
kubectl --context berry -n argocd get applications -l argocd-agent=true
```

詳しいAgentの稼働状態確認や証明書の更新手順、トラブルシューティングについては[Argo CD Agent運用](../operations/argocd-agent.md)を参照してください。

