# MCLによるKubernetes Manifestの評価

## 必須の設計条件

この評価とMCL化では、次の要件を適用します。

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

現在の実装は`k8s/mcl/clusters/kurumi/main.mcl`からTartHost 4台とRedfish用ExternalSecretを、`k8s/mcl/clusters/biscuit/main.mcl`からTartHost 1台とIntel AMT用ExternalSecretを出力します。各クラスタのホスト固有値をレコードに集約し、電源仕様をWakeOnLAN、Redfish、IntelManageabilityのUnionで表します。MCLは共通の`TartHost`生成関数に各レコードの値を渡します。`k8s/mcl/namespaces/`は3クラスタのNamespace resourceを生成し、各出力は既存YAMLと一致します。`k8s/mcl/apps/actions-runners/main.mcl`は5つのrunner用Applicationと4つの関連resourceを出力し、9 resourceすべてが現行Jsonnetと一致します。各runnerのCPU、Memory、Architecture、上限値だけをpresetとして保持し、共通のHelm valuesとApplicationを一度だけ定義します。

Cluster APIではBiscuitとKurumiのcontrol plane、KurumiのworkerをMCL化しました。3つのstackは16 resourceを生成し、既存Jsonnetの各stack出力と完全一致します。共通resource関数はCluster、TartControlPlane、TartMachineTemplate、MachineDeployment、bootstrap template、patch Secretを生成します。Talos patchは既存の`k8s/clusters/*/_patches/`をtext importで読み込みます。Jsonnetがpatch本文などから計算するimmutable resource名のdigest suffixは現在値を固定しています。patchを編集した場合はresource名も手動更新する必要があります。

Argo CD Agent bootstrapではBiscuitとKurumiのstackをMCL化しました。各stackは11 resourceを生成し、既存Jsonnetと一致します。共通Helm valuesとGo templateは`k8s/mcl/clusters/lib/_configs/`に分離し、クラスタ別Cilium valuesも独立したYAMLファイルにしています。Akvoradoは23 resourceを生成し、`k8s/apps/akvorado/_configs/`の設定ファイルを直接読み込みます。Actions Runner hook scriptとTalos patchも既存ファイルを参照します。MCL固有のbootstrap用設定は`k8s/mcl`内の`_configs/`へ分離しました。アプリでは`api-server-proxy`のBackendTLSPolicyとHTTPRoute、`api-server-service-account-issuer-discovery`のClusterRoleBinding、`blackbox-exporter`の14 Helm resourceとNetworkPolicy、`caretta`の5 Helm resourceとPodMonitor、`clusterissuer`の7 resource、`eck-operator`の22 Helm resource、`ephemeral-storage-metrics`の5 resource、`external-dns-cloudflare`の6 Helm resource、`external-secrets`の43 Helm resourceを3クラスタへ配置する構成、`kube-state-metrics`の6 Helm resource、`kubernetes-control-plane-metrics`の15 resource、`metrics-server`の9 Helm resource、`prometheus-node-exporter`の4 Helm resource、`moco`の22 Helm resource、`reloader`の6 resource、`scylla-node-config`のNodeConfig、`smartctl-exporter`の5 Helm resource、`tidb-operator`の4 Helm resource、`topolvm`のKurumi向け33 Helm resourceとBiscuit向け31 Helm resource、`ubuntu-test`のDeployment、`valkey-operator`の10または11 Helm resource、`rabbitmq-cluster-operator`の11 Helm resourceと5つの`before.update` hookをMCL化しました。各アプリのMCL出力を既存のJsonnetまたはHelm出力と比較しています。`eck-operator`ではHelmの`resources.limits.cpu: 1`をMCLのKubernetes Quantity文字列`"1"`として出力します。`ephemeral-storage-metrics`はKurumiの`monitoring` namespace向け配置とHelm valuesをアプリ内のplacement recordに置き、placement indexからrouting情報を出力します。`blackbox-exporter`はHelm valuesとNetworkPolicyを同じentrypointでrenderします。`valkey-operator`はplacement recordにKurumiとBerryの配置先およびprofileの対応を置き、共通`main.mcl`でServiceMonitorの有効・無効を切り替えます。MCLから生成したprofile別Bundleは既存Helm valuesによる出力とそれぞれ一致します。

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

MCL化は24アプリ、3クラスタのNamespace、Biscuit・KurumiのTartHostと資格情報参照、Biscuit・Kurumiのcontrol planeとArgo CD Agent bootstrap、Kurumiのworkerに限られます。残りの93アプリ、全117個の`app.json5` metadataとApplicationSetによるアプリ発見、既存Componentの置き換え、placement-indexからApplicationSetを生成するPlugin Generatorは未実装です。`actions-runners`のimmutable ConfigMap名とCAPI stackのimmutable resource名は現在のJsonnetが生成したdigest suffixを固定値で使っています。scriptやpatchを変更すると対応するdigest suffixも手動で更新する必要があります。MCL側の技術的な改善候補はMCLリポジトリの`docs/reviews/kubernetes-infra-evaluation.md`に記録します。全体の完了判定には、各entrypointのMCL評価、生成Bundleと現行Jsonnet出力の比較、CRDを含むKubernetes schema検証が必要です。
