# MCLによるKubernetes Manifestの評価

## 評価対象

`clusterapi`ブランチの`k8s/`は117個のアプリケーションと、Cluster API/Tart/Talos/Argo CD Agentを管理するクラスタ定義で構成されています。MCL化では既存の`app.json5`やJsonnet Componentを一対一に翻訳せず、アプリケーションの入力データ、共通のリソース関数、entrypointを分け、MCLの型とBundle出力に合わせて構成を見直します。

現在の実装は`k8s/mcl/clusters/kurumi/main.mcl`からTartHost 4台とRedfish用ExternalSecretを、`k8s/mcl/clusters/biscuit/main.mcl`からTartHost 1台とIntel AMT用ExternalSecretを出力します。各クラスタのホスト固有値をレコードに集約し、電源仕様をWakeOnLAN、Redfish、IntelManageabilityのUnionで表します。MCLは共通の`TartHost`生成関数に各レコードの値を渡します。`k8s/mcl/namespaces/`は3クラスタのNamespace resourceを生成し、各出力は既存YAMLと一致します。

## Argo CD Config Management Plugin案

将来のpluginは、Argo CD Applicationのsource pathにある`main.mcl`をentrypointとして、checkout済みGit revisionを入力に`mcl check`と`mcl render`を順に実行します。成功時はYAMLのBundleだけをstdoutへ出力し、診断と実行ログはstderrへ出力します。pluginは環境変数や外部ネットワークの最新値からManifestを生成せず、同じrevisionとlockfileから同じBundleを生成します。

Argo CD Applicationは現在と同じアプリケーション単位を保ちます。各Applicationのsource pathは`k8s/mcl/apps/<app>/main.mcl`、クラスタ構築用Applicationのsource pathは`k8s/mcl/clusters/<cluster>/main.mcl`、Namespace Applicationのsource pathは`k8s/mcl/namespaces/<cluster>/main.mcl`を指す想定です。共通モジュールはMCLの明示的なimportで参照します。HelmとKustomizeはMCL標準Adapterでレンダリングし、取得元とrevisionをlockfileに固定します。Secret値をBundleに含めず、ExternalSecretなどの参照だけを出力します。MCLのプロジェクトrootは`k8s/mcl/`の`mcl.toml`で区切ります。

## MCLに必要な機能

現在のMCLだけでは、既存クラスタ定義にあるTalos patchの再利用と、内容に基づく不変リソース名を同じ抽象度で記述できません。移植を続ける前に、次の機能を追加するか、Plugin側で責務を持つか決める必要があります。

- 任意ファイルを文字列として読み込む標準機能がありません。`manifest.load`はYAMLなどをManifestとして解析するため、Talos patchを`TartBootstrapConfigTemplate`へ文字列として渡す用途には使えません。`import text "../_patches/control-plane.yaml" as patch`のような型付きtext importを追加し、MCLソースと同じプロジェクトroot制約・依存追跡を適用すると、patchの二重管理を避けられます。
- 標準ライブラリに暗号学的hash関数がありません。既存JsonnetはTalos patchやmachine設定からMD5名を生成し、immutable SecretとTemplateを安全に更新しています。MCLには正規化JSON bytesを入力にする`std:crypto.sha256`を追加し、必要な箇所は明示的にdigest長を指定できる形が適切です。Pluginが値を暗黙に書き換える設計は避けます。
- MCL moduleからexportした型を別moduleの型定義で参照できません。`import "./types.mcl" as types`後に`power: types.Power`を宣言すると、現行MCLは`types.Power`をunknown typeとして拒否します。複数クラスタでTart PowerのUnion定義を重複させているため、qualified type importを追加するか、共有型を展開する仕組みが必要です。
- MCLはimport graphを明示的に記述します。117アプリの個別entrypointをpluginがどの単位で発見するか、globをMCL言語へ追加するのか、リポジトリ側のindexを生成するのかを決める必要があります。Argo CDのApplication単位を維持するなら、個別entrypointを明示する現在案が単純です。全アプリを一度にbundle化する用途では、MCLにディレクトリの暗黙探索を追加せず、pluginが管理するApplication一覧から個別entrypointを評価する方が依存関係を追跡できます。

## 未完了項目

MCL化は3クラスタのNamespaceと、Biscuit・KurumiのTartHostおよび資格情報参照に限られます。残りのCluster APIリソース、Talos patch、Argo CD Agent、117アプリ、Helm/Kustomize利用、既存Componentの置き換えは未移植です。全体の完了判定には、各entrypointのMCL評価、生成Bundleと現行Jsonnet出力の比較、CRDを含むKubernetes schema検証が必要です。
