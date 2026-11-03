# MCLによるKubernetes Manifestの評価

## 必須の設計条件

この評価とMCL化では、次の要件を適用します。

ユーザーから受けた指示の原文は[`mcl-evaluation-requirements.md`](mcl-evaluation-requirements.md)に記録しています。この節の要件を確認するときは、原文も参照します。

- `k8s/`配下にREADMEなどのドキュメントを置きません。Kubernetes移行の設計や評価の記録は`docs/`など`k8s/`の外に置きます。
- ConfigMapやHelm valuesなどで数行以上の文字列を書く場合は、文字列を別ファイルに分け、MCLの`import text`で読み込みます。長い文字列をManifest内に埋め込みません。
- 複数クラスタへ同じアプリケーションを配置するときは、各クラスタの配置先クラスタ名とnamespace、およびクラスタごとに異なる設定をアプリケーション自身のディレクトリで宣言します。
- 単一の`main.mcl`を各クラスタで使います。クラスタ数に合わせてentrypointを作成したり、Argo CD Applicationごとに別entrypointへ切り替えたりしません。
- アプリケーションはfeature profileやfeature flagなどクラスタ名に依存しない設定を宣言し、アプリケーション側の配置情報でクラスタと設定値の対応を保持します。MCLのmanifestまたはApplicationSet Generatorがその対応を読み、単一の`main.mcl`へprofile selectorや必要なfeature flagを渡します。クラスタ名を対応関係の検索keyとして使う場合も、検索は配置・設定解決の層に限り、resource定義の条件には使いません。
- `main.mcl`はprofile selectorを受け取り、アプリケーション内の宣言済みprofileから設定を選びます。Manifestの各要素にcluster名の`if`条件を書きません。cluster名によってManifest内の設定を分岐せず、クラスタ固有名に依存した条件分岐を避けます。
- Argo CD側からHelm valuesなどの設定一式を大量の引数として渡しません。アプリケーションの設定値はアプリケーション側に宣言し、Argo CDとGeneratorから渡す値は配置profileを選ぶためのselectorに絞ります。
- 最終的なクラスタ別Manifestを理解するために、baseとoverlayを読み手が頭の中で合成する書き方を避けます。特にKustomize overlayでManifestを上書きし、クラスタごとの出力がoverlayの合成後でないと把握できない構成は使いません。選択するprofileとrender結果の対応がソースから分かるようにします。
- `main.mcl`へすべてのchart設定、profile、resource生成処理を詰め込みません。chart情報、placementとprofileの対応、共通設定、resource生成関数などを責務に応じて別ファイルへ分け、読みやすさを優先します。resourceごとに必ず1ファイルを作る必要はありませんが、`main.mcl`しかない構成なら不要なアプリ専用ディレクトリを作りません。
- placement indexには配置先とprofile selectorなどGeneratorに必要な情報だけを出し、Helm valuesなどのアプリ設定全体をApplicationSet parameterへ複製しません。

## 評価対象

`clusterapi`ブランチの`k8s/`は117個のアプリケーションと、Cluster API/Tart/Talos/Argo CD Agentを管理するクラスタ定義で構成されています。MCL化では既存の`app.json5`やJsonnet Componentを一対一に翻訳せず、アプリケーションの入力データ、共通のリソース関数、entrypointを分け、MCLの型とBundle出力に合わせて構成を見直します。

現在の実装は`k8s/mcl/clusters/kurumi/main.mcl`からTartHost 4台とRedfish用ExternalSecretを、`k8s/mcl/clusters/biscuit/main.mcl`からTartHost 1台とIntel AMT用ExternalSecretを出力します。各クラスタのホスト固有値をレコードに集約し、電源仕様をWakeOnLAN、Redfish、IntelManageabilityのUnionで表します。MCLは共通の`TartHost`生成関数に各レコードの値を渡します。`k8s/mcl/namespaces/`は3クラスタのNamespace resourceを生成し、各出力は既存YAMLと一致します。`k8s/mcl/apps/actions-runners/main.mcl`は5つのrunner用Applicationと4つの関連resourceを出力します。9 resourceの内容は現行Jsonnetと一致し、hook ConfigMap名だけは`std:crypto.sha256`から生成するためdigest suffixが変わります。各runnerのCPU、Memory、Architecture、上限値だけをpresetとして保持し、共通のHelm valuesとApplicationを一度だけ定義します。

Cluster APIではBiscuitとKurumiのcontrol plane、KurumiのworkerをMCL化しました。3つのstackは16 resourceを生成し、resource内容は既存Jsonnetと一致します。MCLのSHA-256導入により、immutable resource名のsuffixは旧JsonnetのMD5値から変わります。共通resource関数はCluster、TartControlPlane、TartMachineTemplate、MachineDeployment、bootstrap template、patch Secretを生成します。Talos patchは既存の`k8s/clusters/*/_patches/`をtext importで読み込み、patch、schematic ID、Talos version、host selector labelsから`std:crypto.sha256`でresource名を計算します。patchやmachine設定を変更するとimmutable resource名も自動で変わります。

Argo CD Agent bootstrapではBiscuitとKurumiのstackをMCL化しました。各stackは11 resourceを生成し、既存Jsonnetと一致します。共通Helm valuesとGo templateは`k8s/mcl/clusters/lib/_configs/`に分離し、クラスタ別Cilium valuesも独立したYAMLファイルにしています。Akvoradoは23 resourceを生成し、`k8s/apps/akvorado/_configs/`の設定ファイルを直接読み込みます。Actions Runner hook scriptとTalos patchも既存ファイルを参照します。MCL固有のbootstrap用設定は`k8s/mcl`内の`_configs/`へ分離しました。アプリでは`api-server-proxy`のBackendTLSPolicyとHTTPRoute、`api-server-service-account-issuer-discovery`のClusterRoleBinding、`blackbox-exporter`の14 Helm resourceとNetworkPolicy、`caretta`の5 Helm resourceとPodMonitor、`clusterissuer`の7 resource、`cloudnative-pg`の24 Helm resource、`eck-operator`の22 Helm resource、`ephemeral-storage-metrics`の5 resource、`external-dns-cloudflare`の6 Helm resource、`external-dns-coredns`の6 Helm resource、`external-secrets`の43 Helm resourceを3クラスタへ配置する構成、`kafka-operator`の17 Helm resource、`keda-http-addon`の24 Helm resource、`kube-state-metrics`の6 Helm resource、`kubernetes-control-plane-metrics`の15 resource、`metrics-server`の9 Helm resource、`onepassword-connect`の6 Helm resource、1 CRD、1 verify hookを3クラスタへ配置する構成、`opentelemetry-operator`の17 Helm resource(4 CRDを含む)と3つのverify hook、`prometheus-node-exporter`の4 Helm resource、`qdrant`の6 Helm resourceと2つのverify hook、`moco`の22 Helm resource、`reloader`の6 resource、`scylla-node-config`のNodeConfig、`seaweedfs-operator`の27 Helm resourceと8つのinstall・upgrade hook、`shumoku`の4 Helm resource、`smartctl-exporter`の5 Helm resource、`tidb-operator`の4 Helm resource、`topolvm`のKurumi向け33 Helm resourceとBiscuit向け31 Helm resource、`ubuntu-test`のDeployment、`valkey-operator`の10または11 Helm resource、`rabbitmq-cluster-operator`の11 Helm resourceと5つの`before.update` hookをMCL化しました。各アプリのMCL出力を既存のJsonnetまたはHelm出力と比較しています。`eck-operator`ではHelmの`resources.limits.cpu: 1`をMCLのKubernetes Quantity文字列`"1"`として出力します。`keda-http-addon`はchart既定値のCPU limit `0.5`が数値としてrenderされschema validationに失敗するため、MCL valuesで3 componentのlimitを等価なQuantity文字列`"500m"`に固定しました。Helmにも同じoverrideを適用した出力は24 resourceすべて一致します。`ephemeral-storage-metrics`はKurumiの`monitoring` namespace向け配置とHelm valuesをアプリ内のplacement recordに置き、placement indexからrouting情報を出力します。`blackbox-exporter`はHelm valuesとNetworkPolicyを同じentrypointでrenderします。`valkey-operator`はplacement recordにKurumiとBerryの配置先およびprofileの対応を置き、共通`main.mcl`でServiceMonitorの有効・無効を切り替えます。MCLから生成したprofile別Bundleは既存Helm valuesによる出力とそれぞれ一致します。`onepassword-connect`はBiscuit、Kurumi、Berryで共通の`main.mcl`を使い、placement recordに3つのdestinationを宣言します。`qdrant`ではHelm YAMLのoctal mode `0755`をMCLが同値のdecimal `493`として出力し、Helmの通常resource、CRD、verify hookを分けて比較しました。

`ghcr-login-secret`は1つの`ClusterExternalSecret`をMCLへ移し、Jsonnet出力との構造化JSON比較で一致を確認しました。

`iwashi-blackbox`はHelm chartの4 resourceとNetworkPolicy 2 resourceを生成し、既存Helm・Jsonnet出力と構造的に一致します。`longhorn-backup`はNode 4 resourceとVolumeSnapshotClassを生成し、既存Jsonnet出力と一致します。`pyroscope`はchartの11 resourceを生成し、Helm出力と一致します。`rabbitmq-default`はRabbitmqClusterとServiceMonitorを生成し、既存Jsonnet出力と一致します。`tailscale`はDeployment、RBAC、ExternalSecretを含む5 resourceを生成し、配置先namespaceを反映した既存出力と一致します。`velero`は13 main phase resourceを生成し、chartの4つのCRD更新hookを`before.create`、`before.update`、`before.rollback` phaseへ出力します。Helm hook以外のresourceとScheduleは既存Helm出力と構造的に一致しますが、ConfigMap `velero`の`data.global`だけ末尾改行が異なります。Helm Adapterの複数行文字列の扱いはMCLリポジトリの`docs/reviews/kubernetes-infra-evaluation.md`へ記録しました。

ExternalSecret自体は名前へのhash suffixを要求しません。dataやtemplateの定義が変わったときに参照先Secret名も変え、環境変数やvolume参照を使うPodの更新を促す必要がある場合だけ、ローカル定義からsuffixを生成します。suffixはremote secretの値をhashしないため、1Passwordなどの値が更新されても名前は変わりません。ExternalSecret名には決定的なJSON表現に対する非暗号学的なFNV-1a 64-bit全長digestを使います。全16桁を保持し、現行のresource名prefixと合わせてKubernetesの63文字制限内に収めます。Podのrolloutを必要としないClusterIssuerのCloudflare token参照は固定名にします。immutable ConfigMapなど内容に基づいて新しいresource名を作る用途では、既存のSHA-256を維持します。

追加した`cilium-ipaddress`はKurumiとBiscuitがそれぞれfeature profileを選び、4つのCRD resourceを出力します。両profileの出力は既存Jsonnetと一致します。`descheduler`はKurumi向け5 Helm resourceを出力し、元valuesによるHelm出力と一致します。`envoy-gateway-class`はKurumi向け6 resourceを出力し、profileでEnvoyProxyのLoadBalancer IPを選びます。6 resourceは既存Jsonnet出力と一致します。`esp32-thermohygrometer-exporter`の2 resourceはExternalSecret名のsuffixをFNV-1a 64-bitへ変更し、suffixを正規化して既存Jsonnet出力との一致を確認します。`gateway-api-crds`はv1.6.1の固定Git commitから12 resourceを生成します。`ghcr-login-secret`は1つの`ClusterExternalSecret`を生成し、既存Jsonnetと一致します。`local-path-provisioner`は8つの最終resourceをMCL内に直接記述し、元のKustomize baseとpatchの出力に一致させました。

`external-snapshotter`はv8.3.0の固定commitからCRDとsnapshot-controllerの12 resourceを生成します。`external-secrets-store`は3クラスタで共通の`main.mcl`を使い、feature profileで同じvault設定を選びます。出力は既存Jsonnetと一致します。`kube-oidc-proxy`は10 resourceを生成し、既存Jsonnet出力と一致します。

追加した`cilium-gateway`は3 resourceを生成し、既存Jsonnet出力と一致します。`cilium-hubble-oauth2-proxy`は3 resourceを生成し、ExternalSecret名をdataからFNV-1a 64-bitで計算し、既存Jsonnetとの比較時はsuffixを正規化します。`cloudnative-pg-barman-cloud-plugin`はv0.15.0のrelease manifestを固定ファイルとして読み込み、namespaceを適用した17 resourceを元のKustomize出力と一致させます。`coredns`は複数行のCorefileを外部ファイルから`import text`で読み込み、10 resourceを生成します。`fitbit-manager`はExternalSecret名を同じFNV-1a 64-bit方式で生成し、suffixを正規化して5 resourceを既存Jsonnet出力と比較します。`opencost`と`samba`もExternalSecret名をdata定義からFNV-1a 64-bitで生成し、workload側からその名前を参照します。`http-dump`は6 resourceを既存Jsonnet出力と一致させます。`priorities`は3つのPriorityClassを1つのentrypointから生成し、既存Jsonnet出力と一致させます。

`snmp-exporter`はchart v9.17.1の7 resourceを生成し、Helmのcanonical出力と一致させます。SNMP設定は`_configs/snmp.yml`へ分離し、`import text`で読み込みます。

`external-dns-cloudflare`はExternalSecret名をdataからFNV-1a 64-bitで生成し、Helm valuesのSecret参照も同じ名前を使います。

`gha-cache-server`はHelm chartの3 resourceとExternalSecret、HTTPRoute、ScaledObject、ServiceMonitorを出力し、合計7 resourceを生成します。Helm outputと既存Jsonnetの4 resourceをそれぞれ構造的に比較しました。ExternalSecretのtargetは固定名を維持し、Helm valuesはprofile fileに分割しています。

`cloudnative-pg-image-catalog`と`opentelemetry-instrumentations`はそれぞれ1つのCustom Resourceを出力し、既存Jsonnetと構造的に一致させます。`vertical-pod-autoscaler`はchart v0.12.0の35 resourceとServiceMonitor 1 resourceを出力し、Helmと既存Jsonnetにそれぞれ一致させます。

`clickhouse-operator`はchart v0.0.6から15 resourceを生成し、Helm出力と構造的に一致させます。`actions-runner-controller`はchart v0.14.2から6 resourceを生成し、既存valuesを使ったHelm出力と構造的に一致させます。

`ipu`は8 resourceを既存Jsonnet出力と一致させます。`mpeg-dash-encoder`は4 resourceを生成し、ExternalSecretのローカルdata定義からFNV-1a 64-bit suffixを計算し、Deploymentの参照にも同じ名前を使います。`netbird`は11 resourceを生成し、ExternalSecretのdata/template定義だけをhashして16桁suffixを作り、全参照に適用します。`radar`はchartの3 resourceとJsonnetの11 resourceを出力し、全件が既存出力と一致します。`victoria-metrics`はchart v0.50.0の12 resourceをHelm出力と一致させます。`terraform-cloud-agent`は2 resource、`zitadel-kubernetes-rbac`は1 resourceを出力し、それぞれ既存Jsonnetと構造的に一致させます。

`tikv-cluster`はTidbClusterと3つのCertificateを出力し、既存Jsonnetと構造的に一致させます。PDとTiKVの複数行設定は`_configs/`の外部ファイルを`import text`で読み込みます。

`nvidia-gpu-operator`はchart v26.7.0から36 resourceを出力します。8 CRDは`bootstrap` phase、19 resourceは通常phase、9 Helm hookは`before.update`、`before.delete`、`after.delete` phaseに分かれ、全resourceを既存Helm出力と比較しました。`scylla-operator`はchart v1.21.1から24 resourceを生成し、Helm出力と一致させます。

`cilium`は同じ`main.mcl`にKurumiの`originCertificateIngress` profileとBiscuitの`gatewayAPI` profileを対応させ、それぞれ63 resourceと29 resourceを生成します。chart既定値のCNI initContainer CPU limitは数値`1`として出力されKubernetes Quantity schemaを満たさないため、両profileで同じ値を文字列`"1"`として指定します。

`envoy-gateway`はchart v1.6.1とValkeyClusterを同じentrypointから出力します。通常resourceは`helm template --no-hooks`と一致し、pre-install/pre-upgrade hookはMCLの`before.create`と`before.update` phaseに出力します。`github-readme-stats`は4つの既存Jsonnet出力と構造的に一致し、ExternalSecret名はdataからFNV-1a 64-bitで生成します。`prometheus-operator-crds`はchart v31.0.1から10 CRDを生成し、Helm出力と一致します。`trivy-operator`はchart v0.36.0から22 resourceを生成し、Helm出力と一致します。

`influxdb`はHelm chart 5 resourceと既存Jsonnetの2 resourceをまとめて7 resource出力し、ExternalSecret名のsuffixを正規化してcanonical outputと比較します。Helm valuesとExternalSecretは同じFNV-1a 64-bit生成名を使います。`longhorn-oauth2-proxy`はExternalSecret、HTTPRoute、SecurityPolicyの3 resourceを生成し、suffixを正規化して既存Jsonnet出力と比較します。

`keda`はbase valuesとKurumi valuesを`standard` profileへまとめ、34 resourceを生成します。KEDA chart既定値のCPU limitはSchema検証でNumberとして拒否されるため、等価なQuantity文字列`"1"`をMCL valuesに明示し、同じoverrideを使ったHelm出力と一致させます。

`loki`はchart v13.2.0から61 resourceを生成し、values YAMLをapp内の外部ファイルから読み込みます。12 resourceのCPU limitはKubernetes QuantityとしてMCL Schemaが要求する文字列に直し、同じ文字列overrideを使ったHelm出力と一致させます。元のHelm出力とは該当フィールドのYAML型だけが異なります。

`grafana`はHelm chartの8 resource、ExternalSecret、VPAを同じentrypointから出力します。Helm valuesとExternalSecretは同じFNV-1a 64-bit生成名を使い、suffixを正規化して既存出力と比較します。複数行のdatasource設定値は外部ファイルを`import text`で読み込みます。

追加移行した`coder`は9 resource、`coder-workspaces`は2 resourceを生成し、Helm/Jsonnet出力と一致させます。`maps`は13 resource、`iwashi-collector`は4 resourceを生成します。`seaweedfs-default`は56 resource、`seaweedfs-biscuit`は7 resource、`postgresql-default`は47 resource、`prfexample`は15 resourceを生成します。`stalwart`は17 resource、`visual-regression-tracker`は9 resourceを生成し、既存出力と比較しました。

`walnuk`は20 resourceを生成し、`iwashi`、`iwashi-cortex`、`iwashi-smtp-relay`もそれぞれ単一entrypointとアプリ内placement/profileからrenderします。`longhorn`はHelm chart 51 resourceと追加resource 8件を出力し、Helm chart分は`helm template --no-hooks`と一致します。`misskey`は16 resource、`netbox`は26 resourceを生成し、FNV suffixやYAML mode表現の変更を正規化して既存出力と比較しました。

`picca`は57 resource、`picca-dev`は26 resourceを生成します。`seaweedfs-default-backup`は6 resourceのimmutable ConfigMapとCronJobを維持し、内容由来のhash suffixをMCLのSHA-256へ移しました。`zitadel`はHelmの通常resource 5件、before hook 6件、delete hook 1件とJsonnetの追加resource 5件を生成します。`oekaki-dengon-game`は18 resource、`opentelemetry-collectors`は10 resourceを既存出力と比較しました。

`walnuts-dev`は8 resource、`scylla-cluster`は6 resource、`scylla-manager`はHelm出力と一致する7 resourceを生成します。`rabbitmq-topology-operator`はchartの通常resource 14件とWebhookConfiguration 1件を出力し、13 CRDをbootstrap phase、pre-upgrade CRD hookを対応するlifecycle phaseへ出力します。chartが無条件で`genCA`を実行するWebhookConfiguration生成はvaluesで無効にし、cert-managerのCA injection annotationを持つ同内容のWebhookConfigurationをMCLで定義しました。

## 複数クラスタでのアプリケーション配置

同じアプリケーションを複数クラスタへ配置する場合も、アプリケーションごとに`main.mcl`を1つだけ用意し、すべての配置でそのentrypointを使います。配置するクラスタ数に応じてentrypointを切り替える構成や、クラスタごとのentrypoint directoryは作りません。

アプリケーション自身のディレクトリに配置recordを置きます。各recordには配置先のcluster、Argo CD destination(namespaceを含む)、およびその配置で選ぶfeature profileを宣言します。Argo CD destinationの`name`と`server`は`kind`で区別します。配置先と設定の対応関係はアプリ側で管理し、ApplicationSet側にアプリ設定を重複して定義しません。

アプリケーション内のprofileはcluster名ではなく、機能の有効・無効を表す名前と値で定義します。たとえば、ServiceMonitorを生成するprofileと生成しないprofileを定義し、各placement recordがどちらを使うか指定します。feature flagを個別に渡す場合も、flagはアプリケーションの機能を表し、cluster名を使った条件判定はresource定義に書きません。KurumiやBerryのようなcluster名は配置recordのrouting情報やclusterと設定値の対応関係を引くkeyとして扱えます。

MCLの`main.mcl`はprofile selectorまたは少数のfeature flagを受け取り、同じアプリケーション内で宣言した設定を使ってBundleを生成します。ApplicationSet Plugin Generatorはアプリ側のplacement indexから配置recordを読み、cluster、destination、namespaceをApplicationのrouting情報に使い、profile selectorまたはfeature flagをMCLへ渡します。Helm valuesやresource設定を多数のApplicationSet parameterに分割して渡す形にはしません。配置一覧の解決とManifestの生成は同じアプリ側の宣言を参照します。

次の実装パターンは禁止します。

- MCLへcluster名をparameterとして渡し、各Manifest要素に`if cluster == "kurumi"`のようなcluster名依存の条件を書いてresourceや設定値を切り替えること。
- Argo CD ApplicationまたはApplicationSetからHelm valuesやアプリ設定一式を大量の引数として渡すこと。アプリ設定はアプリ側で宣言し、Argo CDからは配置profileを選ぶselectorを渡します。
- baseとoverlayを読み手が頭の中で合成しないと、特定clusterの最終Manifestを把握できない構成にすること。Kustomize overlayによる上書きなど、各clusterで有効になるresourceや値がentrypointと選択profileから読めない表現を使いません。
- 複数クラスタ配置を実現するため、clusterごとに別の`main.mcl`やentrypoint directoryを設けること。

`main.mcl`には入力profileの選択とBundleの組み立てを記述し、chart情報、配置record、profile設定、共通values、resource生成関数は役割ごとに別ファイルへ分割します。1 resourceごとに1ファイルを作る必要はありませんが、可読性を優先し、`main.mcl`だけしか置かない構成ならアプリ専用directoryを作りません。

複数行にわたるConfigMap値、shell script、Helm values、Go templateなどは外部ファイルに分け、MCLの`import text`で読み込みます。`k8s/`配下にはREADMEを含む設計文書を置かず、設計記録は`k8s/`外の`docs/`などに置きます。

この配置モデルのApplicationSet連携では、ApplicationSet Plugin Generatorがplacement indexから各配置を発見します。MCLのimport graphは明示し、directoryの暗黙探索でアプリや配置を見つける設計にはしません。

## Argo CD Config Management Plugin案

将来のpluginは、Argo CD Applicationのsource pathにある`main.mcl`をentrypointとして、checkout済みGit revisionを入力に`mcl check`と`mcl render`を順に実行します。成功時はYAMLのBundleだけをstdoutへ出力し、診断と実行ログはstderrへ出力します。pluginは環境変数や外部ネットワークの最新値からManifestを生成せず、同じrevisionとlockfileから同じBundleを生成します。

Argo CD Applicationは現在と同じアプリケーション単位を保ちます。クラスタ構築用Applicationのsource pathは`k8s/mcl/clusters/<cluster>/main.mcl`、Namespace Applicationのsource pathは`k8s/mcl/namespaces/<cluster>/main.mcl`を指します。アプリケーションはクラスタごとにentrypointを分けず、すべての配置で`k8s/mcl/apps/<app>/main.mcl`を使います。

複数クラスタに配置するアプリは、`placements.mcl`でcluster、destination、feature profileの対応を宣言します。destinationは`kind`でArgo CDの`name`と`server`を区別します。アプリは`profiles.mcl`などのapp内ファイルに機能設定を定義し、placement recordからprofileを参照します。たとえばKurumiではServiceMonitorを有効にし、Berryでは無効にする設定を、`monitoring`と`standard`のprofileとして宣言できます。MCLの`main.mcl`は`std:context.parameter("profile")`でprofile selectorを1つ受け取り、アプリ内のprofile mapからHelm valuesなどを読みます。CLIは`mcl render main.mcl --parameter profile=monitoring`のように実行します。ApplicationSet Plugin Generatorはplacement indexからclusterとdestinationを読み、同じprofile selectorをMCLに渡します。GeneratorへHelm valuesなどの設定を個別parameterとして渡しません。manifest要素でcluster名を条件判定せず、cluster名をfeature設定の識別子にも使いません。

`placement-index.mcl`は各配置のtarget、cluster、共通entrypoint、destination、profile名だけをJSON出力し、Helm valuesは出力しません。reloaderのplacement indexはKurumi、Biscuit、Berryの3配置を記録し、全配置で共通の`main.mcl`を使います。KurumiとBiscuitは`standard` profile、BerryはArgo CD namespaceのresourceを再読み込みする`argocdApplicationReload` profileを選びます。両profileの6 resourceは既存Helm出力と一致します。ApplicationSet Generator連携は未実装です。`main.mcl`には入力選択と出力の組み立てだけを記述し、chart情報、placementとprofileの対応、共有values、resource生成関数は別のMCLファイルに分けます。複数行のConfigMap値、shell script、Talos patch、Helm values、Go templateは、`import text`で読む外部ファイルに分離します。HelmとKustomizeはMCL標準Adapterでレンダリングし、取得元とrevisionをlockfileに固定します。Secret値をBundleに含めず、ExternalSecretなどの参照だけを出力します。MCLのプロジェクトrootは`k8s/mcl.toml`で`k8s/`に区切り、MCLのlockfileは`k8s/mcl.lock`に置きます。これにより`k8s/apps/*/_configs`などの既存ファイルをroot制約内から参照できます。

## MCL実装上の課題

インフラ評価から確認したMCL本体の不足、再現性やHelm Adapterに関する改善候補は、MCLリポジトリの`docs/reviews/kubernetes-infra-evaluation.md`に分けて記録します。この設計文書ではinfra側の移行方針、配置モデル、ApplicationSet連携、移行済みアプリケーションと残作業を管理します。

## 未完了項目

MCL化対象117アプリのうち116アプリを移行し、Renovateは対象外とします。3クラスタのNamespace、Biscuit・KurumiのTartHostと資格情報参照、Biscuit・Kurumiのcontrol planeとArgo CD Agent bootstrap、KurumiのworkerもMCL化しました。全117個の`app.json5` metadataとApplicationSetによるアプリ発見、既存Componentの置き換え、placement-indexからApplicationSetを生成するPlugin Generatorは未実装です。各entrypointのMCL評価と現行JsonnetまたはHelm出力との比較を完了しましたが、infra全体のKubernetes schema検証は未完了です。MCL本体に関する技術的な制約と改善候補はMCLリポジトリの`docs/reviews/kubernetes-infra-evaluation.md`で管理します。`actions-runners`のConfigMap名とCAPIのimmutable resource名はhook scriptやTalos machine設定を入力に`std:crypto.sha256`で生成します。
