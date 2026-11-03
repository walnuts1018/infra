# MCLによるKubernetes Manifestの評価

## 評価対象

`clusterapi`ブランチの`k8s/`は117個のアプリケーションと、Cluster API/Tart/Talos/Argo CD Agentを管理するクラスタ定義で構成されています。MCL化では既存の`app.json5`やJsonnet Componentを一対一に翻訳せず、アプリケーションの入力データ、共通のリソース関数、entrypointを分け、MCLの型とBundle出力に合わせて構成を見直します。

現在の実装は`k8s/mcl/clusters/kurumi/main.mcl`からTartHost 4台とRedfish用ExternalSecretを、`k8s/mcl/clusters/biscuit/main.mcl`からTartHost 1台とIntel AMT用ExternalSecretを出力します。各クラスタのホスト固有値をレコードに集約し、電源仕様をWakeOnLAN、Redfish、IntelManageabilityのUnionで表します。MCLは共通の`TartHost`生成関数に各レコードの値を渡します。`k8s/mcl/namespaces/`は3クラスタのNamespace resourceを生成し、各出力は既存YAMLと一致します。`k8s/mcl/apps/actions-runners/main.mcl`は5つのrunner用Applicationと4つの関連resourceを出力し、9 resourceすべてが現行Jsonnetと一致します。各runnerのCPU、Memory、Architecture、上限値だけをpresetとして保持し、共通のHelm valuesとApplicationを一度だけ定義します。

Cluster APIではBiscuitとKurumiのcontrol plane、KurumiのworkerをMCL化しました。3つのstackは16 resourceを生成し、既存Jsonnetの各stack出力と完全一致します。共通resource関数はCluster、TartControlPlane、TartMachineTemplate、MachineDeployment、bootstrap template、patch Secretを生成します。Talos patchは既存の`k8s/clusters/*/_patches/`をtext importで読み込みます。Jsonnetがpatch本文などから計算するimmutable resource名のdigest suffixは現在値を固定しています。patchを編集した場合はresource名も手動更新する必要があります。

Argo CD Agent bootstrapではBiscuitとKurumiのstackをMCL化しました。各stackは11 resourceを生成し、既存Jsonnetと一致します。共通Helm valuesとGo templateは`k8s/mcl/clusters/lib/_configs/`に分離し、クラスタ別Cilium valuesも独立したYAMLファイルにしています。Akvoradoは23 resourceを生成し、`k8s/apps/akvorado/_configs/`の設定ファイルを直接読み込みます。Actions Runner hook scriptとTalos patchも既存ファイルを参照します。MCL固有のbootstrap用設定は`k8s/mcl`内の`_configs/`へ分離しました。アプリでは`api-server-proxy`のBackendTLSPolicyとHTTPRoute、`api-server-service-account-issuer-discovery`のClusterRoleBinding、`clusterissuer`の7 resource、`kubernetes-control-plane-metrics`の15 resource、`reloader`の6 resource、`scylla-node-config`のNodeConfig、`ubuntu-test`のDeploymentをMCL化しました。各アプリのMCL出力は既存のJsonnetまたはHelm出力と一致します。

## Argo CD Config Management Plugin案

将来のpluginは、Argo CD Applicationのsource pathにある`main.mcl`をentrypointとして、checkout済みGit revisionを入力に`mcl check`と`mcl render`を順に実行します。成功時はYAMLのBundleだけをstdoutへ出力し、診断と実行ログはstderrへ出力します。pluginは環境変数や外部ネットワークの最新値からManifestを生成せず、同じrevisionとlockfileから同じBundleを生成します。

Argo CD Applicationは現在と同じアプリケーション単位を保ちます。各Applicationのsource pathは`k8s/mcl/apps/<app>/entrypoints/<deployment>/main.mcl`、クラスタ構築用Applicationのsource pathは`k8s/mcl/clusters/<cluster>/main.mcl`、Namespace Applicationのsource pathは`k8s/mcl/namespaces/<cluster>/main.mcl`を指す想定です。複数クラスタに配置するアプリは、`k8s/mcl/apps/<app>/deployments.mcl`でdeploymentごとのtarget、cluster、entrypoint、destination、Helm valuesを型付きレコードとして宣言します。destinationは`kind`でArgo CDの`name`と`server`を区別します。クラスタ固有の値は各レコードの`values`に置き、`with:`で共通valuesと明示的に合成します。各entrypointは宣言済みの1レコードを選び、cluster名の条件分岐をmanifest要素内に置かずにrenderします。`deployment-index.mcl`は全deploymentからtarget、cluster、entrypoint、destinationだけをJSON出力します。将来のApplicationSet Plugin Generatorは各indexを`mcl render --format json`で評価し、routing情報から各Applicationを生成します。アプリ設定はapp側のdeployment recordに残し、ApplicationSet parameterには渡しません。reloaderの`deployment-index.mcl`はKurumi、Biscuit、Berryの3配置を出力します。Generator連携は未実装です。HelmとKustomizeはMCL標準Adapterでレンダリングし、取得元とrevisionをlockfileに固定します。Secret値をBundleに含めず、ExternalSecretなどの参照だけを出力します。MCLのプロジェクトrootは`k8s/mcl.toml`で`k8s/`に区切り、MCLのlockfileは`k8s/mcl.lock`に置きます。これにより`k8s/apps/*/_configs`などの既存ファイルをroot制約内から参照できます。

## MCLに必要な機能

現在のMCLだけでは、内容に基づく不変リソース名を既存Jsonnetと同じ抽象度で記述できません。移植を続ける前に、次の機能を追加するか、Plugin側で責務を持つか決める必要があります。

- `import text "../_configs/config.yaml" as config`で外部テキストをStringとして読み込めます。MCLの通常importと同じproject root制約を適用し、参照元ファイルを依存関係として追跡します。ConfigMap値、shell script、Talos patch、Helm values、Go templateを独立ファイルで編集できます。
- 標準ライブラリに暗号学的hash関数がありません。既存JsonnetはTalos patchやmachine設定からMD5名を生成し、immutable SecretとTemplateを安全に更新しています。MCL化したCAPI resourceでは現在のdigest suffixを固定値として記述しています。patchなどの入力を変更するときにresource名も手動更新する必要があるため、MCLには正規化JSON bytesを入力にする`std:crypto.sha256`を追加し、必要な箇所は明示的にdigest長を指定できる形が適切です。Pluginが値を暗黙に書き換える設計は避けます。
- MCL moduleからexportした型を別moduleの型定義で参照できません。`import "./types.mcl" as types`後に`power: types.Power`を宣言すると、現行MCLは`types.Power`をunknown typeとして拒否します。複数クラスタでTart PowerのUnion定義を重複させているため、qualified type importを追加するか、共有型を展開する仕組みが必要です。
- MCLは空のMapやListの要素型を推論できない場合があります。Scylla NodeConfigの空の`nodeSelector`と`tolerations`では、ローカルな型注釈が必要です。
- MCLはimport graphを明示的に記述します。117アプリの個別entrypointをpluginがどの単位で発見するか、globをMCL言語へ追加するのか、リポジトリ側のindexを生成するのかを決める必要があります。Argo CDのApplication単位を維持するなら、個別entrypointを明示する現在案が単純です。全アプリを一度にbundle化する用途では、MCLにディレクトリの暗黙探索を追加せず、pluginが管理するApplication一覧から個別entrypointを評価する方が依存関係を追跡できます。

Helm Adapterの未対応例もあります。Envoy Gateway 1.6.1はClusterRoleとRoleの`metadata.creationTimestamp: null`がschema validationに失敗します。cert-manager v1.21.2とtopolvm 17.2.0のcert-manager subchartでは有効なplain scalar内のコロンを含むRBAC名をYAML parserが拒否します。trust-manager 0.24.0は`genCA`によるランダムな証明書生成を使い、再現可能な評価のためにMCLが無効にしている関数を必要とします。external-dns-cloudflare 1.21.1はGitHub Releaseへredirectする公式archiveを使います。MCL 0.3.14ではHTTPS間のredirectを最大10回まで追従し、HTTPへの降格は拒否します。external-dns-cloudflareはMCL標準Helm Adapterでrenderでき、同じvalues、Kubernetes version、API versionsを指定した`helm template`出力と6 resourceが一致します。

## 未完了項目

MCL化は10アプリ、3クラスタのNamespace、Biscuit・KurumiのTartHostと資格情報参照、Biscuit・Kurumiのcontrol planeとArgo CD Agent bootstrap、Kurumiのworkerに限られます。残りの107アプリ、全117個の`app.json5` metadataとApplicationSetによるアプリ発見、既存Componentの置き換え、deployment-indexからApplicationSetを生成するPlugin Generatorは未実装です。`actions-runners`のimmutable ConfigMap名とCAPI stackのimmutable resource名は現在のJsonnetが生成したdigest suffixを固定値で使っています。scriptやpatchを変更してもMCL自身はdigestを更新できないため、hash関数を追加するか、resource名生成を別仕様にする必要があります。全体の完了判定には、各entrypointのMCL評価、生成Bundleと現行Jsonnet出力の比較、CRDを含むKubernetes schema検証が必要です。
