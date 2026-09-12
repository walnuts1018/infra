# kurumi

`kurumi`は`berry`をmanagement clusterとするCluster API + Tart管理のworkload clusterである。正常系の構築はGit、berry上のArgo CD、CAPI、Tart、Talos、CAPI addon、Argo CD Agentの収束に任せ、kurumiへリソースを手動投入しない。

## 構成

- control planeは`cake`、`hotate`、`lemon`の3台で、workerは`rusk`の1台とする。
- TartHostのMAC、管理用IP、ホストラベル、WoLまたはRedfishの設定は`k8s/clusters/kurumi/tart-hosts.jsonnet`が正本である。
- Kubernetes API endpointは`192.168.4.11:6443`で、Talosのfabric BGPがcontrol plane 3台から広告する。
- Pod CIDR、Service CIDR、Talos version、Kubernetes versionは`k8s/clusters/kurumi/cluster.json5`が正本である。
- control planeとworkerのディスクselector、WWID、TopoLVM、Longhorn用extensionは`k8s/clusters/kurumi/_patches/`と各Tart定義が正本である。
- Cilium bootstrap、Argo CD Spoke、Argo CD Agent、1Password root credentialは、`k8s/clusters/kurumi/argocd-agent-bootstrap.jsonnet`から共通componentを通じて配送する。

## 物理要件

`cake`と`hotate`はWoLで電源投入し、`lemon`は初回enrollment前にBIOSでPXEまたはNetwork Bootを有効化してboot orderへ追加する。`rusk`はiLO Redfishの初期設定、PXE、電源操作、対象ディスクの物理接続を完了させる。初回設定後の電源投入、Talos、CNI、Agent、workload applicationの操作はCAPIとGitOpsが担う。

## 最終確認

berry上のCAPIリソースがReadyになり、Argo CDのkurumi向けApplicationが`Synced`かつ`Healthy`になれば正常系の最低限の確認を満たす。

```bash
kubectl --context berry -n kurumi get cluster,tartcluster,tartcontrolplane,machine,machinedeployment
kubectl --context berry -n argocd get applications -l argocd-agent=true
```

詳細なAgent状態、証明書更新、障害調査は[Argo CD Agent運用](../operations/argocd-agent.md)を参照する。
