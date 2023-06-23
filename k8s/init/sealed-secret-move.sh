#!/bin/bash

cd ~/dev/infra/k8s/apps

for file in `ls ./*/sealedsecret*.yaml`; do
    oldname=`yq e .metadata.name $file`
    oldnamespace=`yq e .metadata.namespace $file`
    
    name=`yq e .spec.template.metadata.name $file`
    namespace=`yq e .spec.template.metadata.namespace $file`
    
    yq e .metadata.name = $name -i $file
    yq e .metadata.namespace = $namespace -i $file

    mv $file $(dirname ${file})/sealedsecret2.yaml
    yq write -i postgres-pod.yaml spec.containers[0].image postgres:11
    kubeseal \
    --controller-namespace=kube-system \
    --controller-name=sealed-secrets-controller \
    --namespace=monitoring \
    < $(dirname ${file})/sealedsecret2.yaml \
    --recovery-unseal \
    --recovery-private-key ~/oldSealedSecret/sealed-secrets-key.yaml -o yaml > $(dirname ${file})/secret.yaml
    cat  | kubeseal --controller-name=sealed-secrets-controller --controller-namespace=kube-system --cert ~/currentSealedSecret/SealedSecret.crt -w $file
    \rm $(dirname ${file})/sealedsecret2.yaml $(dirname ${file})/secret.yaml
    
    yq e .metadata.name = $oldname -i $file
    if $oldnamespace != null ; then
        yq e .metadata.namespace = $oldnamespace -i $file
    fi
done
#git add .
#git commit -m "[change] sealedsecret"
#git push
git diff