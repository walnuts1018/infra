# Argo CD Agent運用

## Architecture

`berry`はArgo CD Principal、ApplicationSet、cert-manager、External Secretsを実行する。`kurumi`と`biscuit`はArgo CD Spoke、application-controller、repo-server、Redis、Agentを実行し、Applicationの実体をworkload cluster内でreconcileする。通常系のworkload clusterへの導入はClusterResourceSetとHelmChartProxyが行う。

Agentの接続先は`argocd-agent.local.walnuts.dev:443`である。Principalの証明書、CA、workload clusterごとのclient certificateはcert-managerがberry上で発行する。Principalがself-registrationで作成するcluster Secretには、Argo CDがresource proxyへ接続するための共有client certificateが含まれる。

## Self-registration

各Clusterの`argocd-agent.walnuts.dev/enabled: "true"`ラベルをselectorに使用する。共通bootstrap componentは、workload clusterごとに次をberryからCAPI addon経由で配送する。

- `argocd-agent-client-tls`と`argocd-agent-ca`を含むresource-set Secret
- Argo CD SpokeとAgentのHelmChartProxy
- SpokeがAgent用Secretを読むためのServiceAccount、Role、RoleBinding、ClusterSecretStore、ExternalSecret

Agentが有効なclient certificateでPrincipalへ接続すると、Principalが`skip-reconcile`付きcluster Secretを生成する。以後のApplicationSetはberryのApplicationを生成し、destination-based mappingでAgentへ転送する。

## Root material

PrincipalのJWT signing keyは`argocd-agent-jwt` Secretの`jwt.key`キーを使用する。Secretは1Passwordの`argocd-agent-jwt`Document itemにある`jwt.key`ファイルからExternalSecretが同期する。`allowGenerate`は無効であり、`argocd-agentctl jwt create-key`を正常系で実行しない。

証明書のprivate keyとJWT signing keyはGitへ保存しない。証明書はcert-manager、JWT signing keyは1PasswordとExternalSecretをsourceとする。1Password sourceの更新後はExternalSecretの再同期を待ち、PrincipalとAgentの再起動が必要な場合だけ次のtaskを実行する。

```bash
mise run argocd-agent:restart kurumi
mise run argocd-agent:restart biscuit
```

## 状態確認

```bash
kubectl --context berry -n argocd get deployment argocd-agent
kubectl --context berry -n argocd get externalsecret argocd-agent-jwt secret argocd-agent-jwt
kubectl --context berry -n argocd get secret cluster-kurumi cluster-biscuit
kubectl --context berry -n kurumi get helmchartproxy,clusterresourceset,externalsecret
kubectl --context berry -n biscuit get helmchartproxy,clusterresourceset,externalsecret
kubectl --context kurumi -n argocd get pods
kubectl --context biscuit -n argocd get pods
```

Principalのself-registration labelが付いたcluster Secret、workload cluster内のSpokeとAgentのReady状態、Agentの接続ログ、Agent label付きApplicationの`Synced`と`Healthy`を確認する。これらは障害調査の読み取り操作であり、正常系の導入手順ではない。

## Troubleshooting

`argocd-agent-jwt` Secretが存在しない場合は、berryのExternalSecret status、`onepassword` ClusterSecretStore、1PasswordのDocument item名と`jwt.key`ファイルを確認する。Secretをmanifestへ埋め込んだり、Agentの起動時生成を有効にしたりしない。

JWT signing keyをrotationした場合は、ExternalSecretの同期後にberryのPrincipalを再起動して新しいkeyを読み込ませる。

```bash
kubectl --context berry -n argocd rollout restart deployment/argocd-agent
kubectl --context berry -n argocd rollout status deployment/argocd-agent --timeout=5m
```

workload clusterの`onepassword` namespaceまたはroot Secretが存在しない場合は、berryの対象namespaceで`onepassword-bootstrap` ExternalSecretとClusterResourceSetのstatusを確認する。root Secretはworkload clusterへ手動作成せず、resource-setの再同期を待つ。

Agent Podが起動しない場合は、対象namespaceのSpokeとAgent HelmChartProxy、CAPI addon provider、`argocd-agent-client-tls`、`argocd-agent-ca`、Principal endpointの名前解決とTCP接続を確認する。TLS Secretをberryから手動コピーしない。

cluster Secretがself-registrationされない場合は、PrincipalとAgentのログ、client certificateのSubject、Principalの共有client certificate、`argocd-agent.walnuts.dev/enabled` label、Principalのself-registration設定を確認する。`argocd-agentctl agent create`で代替登録しない。

Applicationが同期しない場合は、berryのApplicationSet生成結果、AppProjectのdestination、Applicationの`argocd-agent=true` label、Agentのresource proxy接続、workload clusterのapplication-controllerログを順に確認する。
