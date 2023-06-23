#!/bin/bash

cd ~/dev/infra/k8s/apps

for file in `ls ./*/sealedsecret.yaml`; do
    echo "----------------------------------------------"

    oldname=`yq e .metadata.name $file`
    oldnamespace=`yq e .metadata.namespace $file`
    
    name=`yq e .spec.template.metadata.name $file`
    namespace=`yq e .spec.template.metadata.namespace $file`
    
    NAME=$name yq -i '.metadata.name = strenv(NAME)'  $file
    NAMESPACE=$namespace yq -i '.metadata.namespace = strenv(NAMESPACE)' $file

    echo "yq metadata rewrite done"

    mv $file $(dirname ${file})/sealedsecret2.yaml
    kubeseal \
    --controller-namespace=kube-system \
    --controller-name=sealed-secrets-controller \
    --namespace=monitoring \
    < $(dirname ${file})/sealedsecret2.yaml \
    --recovery-unseal \
    --recovery-private-key ~/oldSealedSecret/sealed-secrets-key.yaml -o yaml > $(dirname ${file})/secret.yaml

    if [ $? -gt 0 ]; then
        mv $(dirname ${file})/sealedsecret2.yaml $file
    else
        cat $(dirname ${file})/secret.yaml | kubeseal --controller-name=sealed-secrets-controller --controller-namespace=kube-system --cert ~/currentSealedSecret/SealedSecret.crt -w $file
        \rm $(dirname ${file})/sealedsecret2.yaml $(dirname ${file})/secret.yaml
    fi

    OLDNAME=$oldname yq -i '.metadata.name = strenv(OLDNAME)' $file
    if [ "$oldnamespace" = "null" ] ; then
        yq -i 'del(.metadata.namespace)' $file
    else
        OLDNAMESPACE=$oldnamespace yq -i '.metadata.namespace = strenv(OLDNAMESPACE)' $file
    fi
done
#git add .
#git commit -m "[change] sealedsecret"
#git push