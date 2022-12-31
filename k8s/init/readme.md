## 構成
 kurumi-01 (Controll) RaspberryPi 4 4GB aarch64 
 
 kurumi-02 RaspberryPi 4 2GB aarch64
 
 (kurumi-03 QEMU 2Core 2GB amd64)
   
## テスト段階
   
### k3s
   
#### インストール
   
```
/boot/cmdline.txtにcgroup_memory=1 cgroup_enable=memory追加
curl -sfL https://get.k3s.io |INSTALL_K3S_VERSION=v1.24.9+k3s1 sh -s - --write-kubeconfig-mode 644
https://kmc-jp.slack.com/archives/C04D8PNLYD6/p1672406980885349 より1.25でもいけそう
```

#### Longhorn
```
sudo apt -y install open-iscsi
```
おもったほど軽くないし、せっかくマシンも強化されたし普通にk8sでいいや

### k8s
version=1.25.5-00
https://qiita.com/greenteabiscuit/items/6fce805185350eab6f7a
忘れてはならない
```
$ kubectl taint node $HOSTNAME node-role.kubernetes.io/control-plane:NoSchedule-
$ kubectl taint node $HOSTNAME node-role.kubernetes.io/master:NoSchedule-
```
#### helmまとめなきゃ、fluxcdとかでrepoとかも含めていい感じにできるのかな？
version=3.10.3-1
metricss-server
				helm repo add metrics-sercer https://kubernetes-sigs.github.io/metrics-server/
				helm install metrics-server --namespace=kube-system metrics-sercer/metrics-server -f ./helm.yaml

## 
