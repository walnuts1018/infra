# Bootstrap

この手順は、完全に初期化された物理マシンから`berry`を起動し、GitOpsへhandoffするまでを扱う。既存クラスター、既存PV、Longhorn、SeaweedFSのデータ移行は対象外とする。

## 前提

- `berry`はRaspberry Pi OS上のmanagement clusterとする。
- `kurumi`と`biscuit`の物理ホストは、各クラスター文書に記載したPXE、BMC、AMT、WoL、ディスク接続を設定する。
- 1Password vault`kurumi`から、berryのConnect root credentialとAgent JWT signing keyを取得できる状態にする。JWT signing keyは`argocd-agent-jwt`というDocument itemの`jwt.key`ファイルにPKCS#8 PEM形式で保存する。
- `docs/bootstrap/berry.md`のroot Secretを作成できる入力ファイルとConnect tokenを用意する。secret valueはGitへ保存しない。

## 手順

1. `docs/bootstrap/berry.md`に従って`berry`のOS、ネットワーク、k3s、root Secret、Argo CDを準備する。
2. `berry`でArgo CDが起動した後、次のコマンドだけをhandoff pointとして実行する。

   ```bash
   kubectl --context berry apply -f k8s/_argocd/entrypoint/base.yaml
   ```

3. 以後はGitとberry上のArgo CDに任せる。Cluster API Operator、Tart provider、Cluster、Cilium、Argo CD Spoke、Argo CD Agent、workload clusterの1Password root credential、ApplicationSet、workload applicationは、リポジトリの定義から自動的に収束する。1Password root credentialは、Agent bootstrapと同じCAPI addon経路で`onepassword-connect`の起動前に配送される。
4. 完了確認はberry上のCAPIリソースとArgo CD Applicationの状態で行う。workload clusterへ個別の`kubectl`、`helm`、Secret投入、TLS Secretコピー、Agent CLIを実行しない。

障害調査、証明書更新後のAgent再起動、Principalの状態確認は[Argo CD Agent運用](../operations/argocd-agent.md)で扱う。
