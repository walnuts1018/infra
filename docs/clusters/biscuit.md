# biscuit

`biscuit`は、管理クラスタ`berry`のCluster API(CAPI)とTart providerによって管理されるワークロードクラスタです。

クラスタの構築や運用は、Git、`berry`上のArgo CD、CAPI、Tart、Talos、CAPI addon、Argo CD AgentによるGitOpsで自動収束します。そのため、クラスタに対して直接手動でリソースを投入する必要はありません。

## クラスタ構成

- `eclair`1台でControl Plane兼Workerを構成します。
- TartHostのMACアドレス、管理用IP、Intel AMT/MEBxエンドポイント、ホストラベルなどは[`k8s/clusters/biscuit/tart-hosts.jsonnet`](../../k8s/clusters/biscuit/tart-hosts.jsonnet)で定義します。
- KubernetesやTalosのバージョン、ノード数は[`k8s/clusters/biscuit/cluster.json5`](../../k8s/clusters/biscuit/cluster.json5)で管理します。
- Kubernetes APIエンドポイントは`192.168.0.15:6443`です。
- 240GB SSDをTalosのシステム領域およびswapに使用し、1TB HDDをLVM(`hdd`ボリュームグループ)およびTopoLVMに使用します。ディスクのselectorやWWID定義は[`k8s/clusters/biscuit/_patches/control-plane.yaml`](../../k8s/clusters/biscuit/_patches/control-plane.yaml)で管理します。
- SeaweedFSはTopoLVM上の単一Pod構成で、マニフェストは[`k8s/apps/seaweedfs-biscuit`](../../k8s/apps/seaweedfs-biscuit)で定義します。バケット作成やライフサイクル設定などの初期化後タスクはTerraformで管理します(詳細は[Terraform運用](../operations/terraform.md)を参照してください)。
- Cilium、Argo CD Spoke/Agent、1Password root認証情報は、[`k8s/clusters/biscuit/argocd-agent-bootstrap.jsonnet`](../../k8s/clusters/biscuit/argocd-agent-bootstrap.jsonnet)経由でkurumiと共通の構成で自動配布されます。

## 物理要件と事前準備

物理マシン`eclair`の事前準備として以下を設定します。

- BIOSでPXEブートを有効化し、ブート順序(Boot Order)を設定します。
- Intel AMT/MEBxの初期ユーザー・パスワードを設定し、Network Bootを有効化します。
- SSDとHDDを所定のポートへ接続します(ドライブ換装時はサイズやWWIDを確認し、マニフェスト側のselectorを更新してください)。

初期設定完了後の電源投入、Talosのインストール、CNI、TopoLVM、SeaweedFS、Agent、各種ワークロードのデプロイは、すべてCAPIとGitOpsが自動で行います。

## 動作確認

`berry`上でCAPIリソースが`Ready`になり、Argo CDのbiscuit向けApplicationが`Synced`かつ`Healthy`になっていれば正常に起動・連携されています。

```bash
kubectl --context berry -n biscuit get cluster,tartcluster,tartcontrolplane,machine,machinedeployment
kubectl --context berry -n argocd get applications -l argocd-agent=true
```

詳しいAgentの稼働状態確認や証明書の更新手順、トラブルシューティングについては[Argo CD Agent運用](../operations/argocd-agent.md)を参照してください。


