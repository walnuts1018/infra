# kurumi構築

## 構成

`kurumi`はTalos上のCAPI管理クラスターとして`berry`から構築する。control planeはcake、hotate、lemonの3台、workerはruskの1台とする。Kubernetes APIのcontrol plane endpointとOIDC issuerは、TalosのBGPで広告する`192.168.4.11:6443`を使用する。

旧Ubuntu、CRI-O、kubeadm、nginx、keepalived環境を並行稼働させない。旧環境を停止する前に、LonghornとSeaweedFSのバックアップおよび復旧可能性を確認する。

## 事前確認

次の確認を完了するまで、ディスクのwipeを有効にしない。

```bash
kubectl --context berry get cluster,tartcontrolplane,machinedeployment -n kurumi
talosctl get disks --nodes 192.168.0.25,192.168.0.26,192.168.0.19,192.168.0.101 -o yaml
kubectl --context kurumi get nodes
kubectl --context kurumi -n longhorn get nodes,volumes,replicas
kubectl --context kurumi get pv,pvc -A
```

control planeのOSディスクは各ホストの`k8s/clusters/kurumi/_patches/control-plane.yaml`、workerのOSディスクとTopoLVM用ディスクは`_patches/worker.yaml`のWWIDと一致することを確認する。追加ディスクの識別に失敗した場合は、Talosの設定を変更してから再実行し、推測でディスクを指定しない。

## Longhorn移行

移行前にLonghornのreplicaがHealthyであること、退避対象のvolumeが確認できること、PVから対応するLVとTalos volumeを追跡できることを記録する。Longhornのデータはアプリケーション単位で外部バックアップを取得し、復元対象と復元順序を記録する。

cakeの追加ディスクは`longhorn-extra`としてTalosが`/var/mnt/longhorn-extra`へ公開する。クラスター復旧後にLonghornのnode diskとして登録し、既存のreplica配置と容量を確認する。Talos volume、LVM、PV、Longhorn replicaの対応が確認できない場合は、対象ディスクをwipeしない。

## CAPI構築

`berry`のArgo CDから`k8s/clusters/kurumi`を適用し、TartHostの割り当て、PXE/DHCP、Talos bootstrap、control planeの起動を順に確認する。

```bash
kubectl --context berry apply -f k8s/_argocd/applications/berry/clusters.yaml
kubectl --context berry -n kurumi get tartcluster,tartcontrolplane,machine,machinedeployment
kubectl --context berry -n kurumi describe tartcontrolplane kurumi
```

control plane 3台がReadyになり、各ノードのTalos APIとKubernetes APIが応答することを確認する。control plane endpointは`192.168.4.11:6443`で疎通し、VyOSに`192.168.4.11/32`の経路が3台から広告されることを確認する。

```bash
talosctl --nodes 192.168.0.25,192.168.0.26,192.168.0.19 get members
talosctl --nodes 192.168.0.25,192.168.0.26,192.168.0.19 get volumestatus
kubectl --context kurumi get nodes -o wide
kubectl --context kurumi get --raw='/readyz?verbose'
```

workerのMachineを作成し、ruskがReadyになった後にCNI、Longhorn、SeaweedFS、Argo CD Agentの順で状態を確認する。Agentが登録されるまで、通常Applicationを手動でworkload clusterへ適用しない。

## Swap

control planeとworkerには、各OSディスクをbacking deviceとする4GiBの`SwapVolumeConfig`を作成する。`KubeletConfig`の`LimitedSwap`は維持する。

```bash
kubectl --context kurumi get nodes -o json | jq '.items[] | {name: .metadata.name, swap: .status.nodeInfo.swap}'
talosctl --nodes 192.168.0.25,192.168.0.26,192.168.0.19,192.168.0.101 get volumestatus
```

Swap volumeが作成されない場合は、backing deviceのWWIDとTalosの`VolumeStatus`を確認する。swapを理由にシステムディスクやLonghornデータを削除しない。

## OIDCとSeaweedFS STS

新クラスターではJWTの`iss`を`https://192.168.4.11:6443`へ切り替える。SeaweedFS STSのKubernetes providerは同じissuer、`https://kubernetes.default.svc/openid/v1/jwks`のJWKS URI、Podの`kube-root-ca.crt`に対応するCAを使用し、ServiceAccount tokenのaudienceは`sts.seaweedfs.com`とする。source bucket消失後のバックアップはprefix purgeまで30日追跡し、B2のhidden version lifecycleがさらに30日保持するため、実効的なrecoverabilityは最大約60日である。

```bash
kubectl --context kurumi create token seaweedfs-default-backup \
  -n seaweedfs --audience=sts.seaweedfs.com > /tmp/seaweedfs-token
python3 - <<'PY'
import base64, json
token = open('/tmp/seaweedfs-token').read().strip()
payload = token.split('.')[1] + '=='
print(json.loads(base64.urlsafe_b64decode(payload)))
PY
curl --cacert /path/to/kurumi-ca.crt \
  https://192.168.4.11:6443/.well-known/openid-configuration
curl --cacert /path/to/kurumi-ca.crt \
  https://192.168.4.11:6443/openid/v1/jwks
```

JWTの`iss`、OIDC discoveryの`jwks_uri`、JWKSによる署名検証を確認した後、SeaweedFS STSのWebIdentity交換を確認する。最後にバックアップCronJobからsource bucketの追加、更新、削除を実行し、rcloneのrelay認証とB2認証が成功することを確認する。静的なSTS設定のrender成功は、実際のJWT署名検証やWebIdentity交換の成功を意味しない。

## Argo CD Agent

`berry`のArgo CDが`argocd-spoke-kurumi`と`argocd-agent-kurumi`を管理する。Agentの証明書とbootstrap resourceは、cert-manager、External Secrets、ClusterResourceSet、HelmChartProxyの依存順に作成される。

```bash
kubectl --context berry -n argocd get application argocd-spoke-kurumi argocd-agent-kurumi
kubectl --context kurumi -n argocd get pods
kubectl --context kurumi -n argocd get secret argocd-agent-client-tls argocd-agent-ca
kubectl --context berry get secret cluster-kurumi
```

## 1Password Connect

`onepassword-connect`は`kurumi`上で動作し、External Secretsの`ClusterSecretStore`から参照される。fresh buildではArgo CD同期前にroot credential seedだけを手動で作成する。

```bash
kubectl create namespace onepassword --context kurumi
kubectl create secret generic op-credentials -n onepassword --context kurumi \
  --from-literal=1password-credentials.json="$(op read 'op://kurumi/k8s Credentials File/1password-credentials.json')"
kubectl create secret generic onepassword-token -n onepassword --context kurumi \
  --from-literal=token="$(op read 'op://kurumi/pcookjymtl2zwyozhofaco5yhy/credential')"
```

`onepassword-connect` Applicationが同期され、Connectのreadinessと`ClusterSecretStore`のReadyを確認してから、Connectを参照するExternalSecretを同期する。

通常のNamespaceは公開・privateのApplicationSetが`app.json5`の`namespace`を配置先として`CreateNamespace=true`で作成する。`namespaces-kurumi`はCiliumのPSA設定が必要な`cilium-system`と、Ciliumが自動作成しない`cilium-secrets`だけを明示manifestで管理する。private側の`adguard`もNamespace Applicationの明示manifestで管理する。

証明書更新後はAgentを再起動する。

```bash
mise run argocd-agent:restart kurumi
```

## 依存順

CNIとKubernetes APIのReady、Longhornのreplica状態、SeaweedFSの`/readyz`、S3 bucketの読み書き、Argo CD Agentの登録を順に確認する。これらは独立したArgo CD Applicationとしてreconcileされるため、Application間の同期順をsync-waveで保証しない。依存リソースが未準備なら同期が失敗し、self-healによる再同期で収束する。厳密なApplication間順序が必要になった場合はProgressive Syncなど専用の仕組みを導入する。

## VIPとBGP

Talosの`fabric` BGP instanceだけがVyOS(ASN 65001)とpeerし、control plane 3台から`192.168.4.11/32`を広告する。Ciliumのservice-BGPは標準のcontrol-plane node labelを持つcontrol planeで動作し、node内の`veth-cilium`(`10.255.255.0/31`)からTalosの`cilium` instance(`10.255.255.1/31`、VRF table 89)へ接続する。Talosの`cilium` instanceは`installRoutes: false`でLB pool(`192.168.12.0/24`)を受信し、`fabric` instanceの`importRoutes`がVyOSへ再広告するため、VyOSとの外向きservice-BGP sessionはTalosだけが持つ。

`fabric`のBGP router-idは3台で重複させない。control planeで共有するpatchにはnode固有のrouter-idを表現できないため、生成されたTalos configとVyOSのBGP neighbor stateで各nodeのrouter-idが異なることを確認できるまで、実機構築を完了扱いにしない。

次のコマンドで、control plane全台のTalos側peerとCilium側peerがEstablishedになり、Talosのfabric側にAPI VIPとLB pool内の経路が存在することを確認する。

```bash
talosctl --nodes 192.168.0.25,192.168.0.26,192.168.0.19 get bgppeerstatus
kubectl --context kurumi -n cilium-system exec daemonset/cilium -- cilium bgp peers
```

control plane 1台のkube-apiserverだけを停止する障害試験では、停止nodeの`192.168.4.11/32`広告が残るか、残り2台へのAPI接続が安定するかを別々に確認する。TalosのBGP広告は標準ではインターフェースとBGP sessionの状態に基づくため、kube-apiserverの`/readyz`とは連動しない。停止nodeの経路が残る場合にECMP経由のAPI接続が失敗するなら、health-awareなVIP広告または外部health checkを導入するまで移行を完了扱いにしない。

## ロールバック境界

Talos bootstrapまたはAPIのReady確認に失敗した場合は、ディスクをwipeせず旧環境へ戻す。旧環境からの読み書き、Longhorn replica、SeaweedFS S3、Argo CDの状態を確認してから再試行する。

ディスクをwipeした後は旧環境へ戻さず、LonghornのバックアップまたはB2から復元する。復元ではTalos、TopoLVM、Longhorn、SeaweedFS、Kubernetesワークロードの順に再構築し、各段階でreadinessとデータ整合性を確認する。復元訓練を完了するまでRTOを実績値として扱わない。

## CIDR制約

`kurumi`と他クラスターのPod CIDRおよびService CIDRは現状変更しない。現在はArgo CD Agentによる管理経路のみを使用する。ClusterMeshやMCSを導入する前に、相互に重複しないCIDRへ移行する必要がある。
