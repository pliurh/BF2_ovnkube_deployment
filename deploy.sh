#!/bin/bash
set -euxo pipefail
# set the kubeconfig of tenant cluster
TENANT_KUBECONFIG="kubeconfig.tenant"

rm -rf template/.generated/*
oc get cm --kubeconfig=${TENANT_KUBECONFIG} -n openshift-ovn-kubernetes ovnkube-config -o json | jq -j '.data."ovnkube.conf"' > template/.generated/ovnkube.conf
oc get cm --kubeconfig=${TENANT_KUBECONFIG} -n openshift-ovn-kubernetes ovn-ca -o json | jq -j '.data."ca-bundle.crt"' > template/.generated/ca-bundle.crt
oc get cm --kubeconfig=${TENANT_KUBECONFIG} -n openshift-ovn-kubernetes kube-root-ca.crt -o json | jq -j '.data."ca.crt"' > template/.generated/ca.crt

oc get secret --kubeconfig=${TENANT_KUBECONFIG} -n openshift-ovn-kubernetes ovn-cert -o json | jq -j '.data."tls.crt"' | base64 --decode > template/.generated/tls.crt
oc get secret --kubeconfig=${TENANT_KUBECONFIG} -n openshift-ovn-kubernetes ovn-cert -o json | jq -j '.data."tls.key"' | base64 --decode > template/.generated/tls.key

TOKEN=$(oc get sa --kubeconfig=${TENANT_KUBECONFIG} -n openshift-ovn-kubernetes ovn-kubernetes-node -o yaml| grep node-token | awk '{print $3}'| xargs -I {} oc get secret --kubeconfig=${TENANT_KUBECONFIG} -n openshift-ovn-kubernetes -o json {} |jq -j '.data.token' | base64 --decode)
cat <<EOF > template/.generated/custom-env.yaml
- op: add
  path: /spec/template/spec/containers/1/env/-
  value:
    name: K8S_TOKEN
    value: '${TOKEN}'
EOF

# kustomize build template
oc apply -k template/
