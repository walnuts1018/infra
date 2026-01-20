<p align="center">
    <a href="https://walnuts.dev" alt="Walnuts.dev">
        <img src="./static/logo.png" alt="walnuts" width="430px" />
    </a>
</p>

<p align="center">
    <img src="https://argocd.walnuts.dev/api/badge?project=default&revision=true" alt="argocd project status" />
    <img src="https://github.com/walnuts1018/infra/actions/workflows/snapshot.yaml/badge.svg" alt="k8s CI" />
    <a href="https://walnuts.dev" alt="Walnuts.dev">
        <img alt="Walnuts.dev Status" src="https://img.shields.io/website?url=https%3A%2F%2Fwalnuts.dev&label=Walnuts.dev">
    </a>
</p>

# Infra

walnuts.dev を支える技術

Walnuts 家の自宅サーバ全般のリポジトリです。

## Kubernetes Manifests

- [README](https://github.com/walnuts1018/infra/tree/main/k8s#readme)

### YAML

このリポジトリではjsonnetを用いてマニフェスト管理を行っています。
YAMLの生成結果は[snapshot](https://github.com/walnuts1018/infra/tree/snapshot)ブランチへと自動的にpushされるので、そちらを参照してください。


## Renovate

- [renovate.json](./renovate.json5)

![Alt](https://repobeats.axiom.co/api/embed/dd585ab5402819b2c5e92a25cbd4dc2304035170.svg "Repobeats analytics image")
