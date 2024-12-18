<p align="center">
    <a href="https://walnuts.dev" alt="WakaTime">
        <img src="./static/logo.png" alt="walnuts" width="430px" />
    </a>
</p>

<p align="center">
    <img srtc="https://argocd.walnuts.dev/api/badge?project=default&revision=true" alt="argocd project status" />
    <img src="https://walnuts1018.github.io/infra/k8sStatus.svg" alt="k8s Status" />
    <img src="https://walnuts1018.github.io/infra/podStatus.svg" alt="Pod Status" />
    <img src="https://walnuts1018.github.io/infra/nodeStatus.svg" alt="Node Status" />
    <img src="https://github.com/walnuts1018/infra/actions/workflows/snapshot.yaml/badge.svg" alt="k8s CI" />
    <img alt="Walnuts.dev Status" src="https://img.shields.io/website?url=https%3A%2F%2Fwalnuts.dev&label=Walnuts.dev">
    <a href="https://wakatime.com/badge/user/981e52dd-a7ab-4b00-9a71-125be9dc2de6/project/07d86b66-ede6-45aa-a456-0985d4aed1a9.svg" alt="WakaTime">
        <img src="https://wakatime.com/badge/user/981e52dd-a7ab-4b00-9a71-125be9dc2de6/project/07d86b66-ede6-45aa-a456-0985d4aed1a9.svg" alt="WakaTime" />
    </a>
</p>

# Infra

walnuts.dev を支える技術

Walnuts 家の自宅サーバ全般のリポジトリです。

## Kubernetes Manifests

- [README](./k8s/README.md)

### YAML

このリポジトリではjsonnetを用いてマニフェスト管理を行っています。
YAMLの生成結果は[snapshot](https://github.com/walnuts1018/infra/tree/snapshot)ブランチへと自動的にpushされるので、そちらを参照してください。


## Renovate

- [renovate.json](./renovate.json5)

![Alt](https://repobeats.axiom.co/api/embed/dd585ab5402819b2c5e92a25cbd4dc2304035170.svg "Repobeats analytics image")
