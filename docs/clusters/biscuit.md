# biscuit

`biscuit`は`berry`をmanagement clusterとするCluster API + Tart管理のworkload clusterである。正常系の構築はGit、berry上のArgo CD、CAPI、Tart、Talos、CAPI addon、Argo CD Agentの収束に任せ、biscuitへリソースを手動投入しない。

## 構成

- `eclair` 1台をcontrol plane兼workerとして使用する。
- TartHostのMAC、管理用IP、Intel Manageability endpoint、ホストラベルは`k8s/clusters/biscuit/tart-hosts.jsonnet`が正本である。
- Kubernetes API endpointは`192.168.0.15:6443`である。
- Talos version、Kubernetes version、ノード数は`k8s/clusters/biscuit/cluster.json5`が正本である。
- 240GB SSDはTalos system領域とswap、1TB HDDは`hdd`ボリュームグループとTopoLVMに使用する。disk selectorとWWIDは`k8s/clusters/biscuit/_patches/control-plane.yaml`が正本である。
- SeaweedFSはTopoLVM上の単一Pod構成で、`k8s/apps/seaweedfs-biscuit`が宣言する。bucketとlifecycleを管理するpost-bootstrap Terraformは[Terraform運用](../operations/terraform.md)で分離して扱う。
- Cilium bootstrap、Argo CD Spoke、Argo CD Agent、1Password root credentialは、`k8s/clusters/biscuit/argocd-agent-bootstrap.jsonnet`からkurumiと同じ共通componentで配送する。

## 物理要件

`eclair`はBIOSでPXEとboot orderを設定し、Intel AMTまたはMEBxの初期ユーザー、パスワード、Network Bootを設定する。SSDとHDDを正しいポートへ接続し、交換時は現在のsizeとWWIDを確認してからGitのselectorを更新する。初回設定後の電源操作、Talos、CNI、TopoLVM、SeaweedFS、Agent、workload applicationの操作はCAPIとGitOpsが担う。

## 最終確認

berry上のCAPIリソースがReadyになり、Argo CDのbiscuit向けApplicationが`Synced`かつ`Healthy`になれば正常系の最低限の確認を満たす。

```bash
kubectl --context berry -n biscuit get cluster,tartcluster,tartcontrolplane,machine,machinedeployment
kubectl --context berry -n argocd get applications -l argocd-agent=true
```

詳細なAgent状態、証明書更新、障害調査は[Argo CD Agent運用](../operations/argocd-agent.md)を参照する。
