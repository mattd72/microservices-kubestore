#!/usr/bin/env bash


NAMESPACE="mongodb"
MDB="product-service-mdb"



generate_cert_for_client () {
    client="${1}"
    cat <<EOF | cfssl genkey - | cfssljson -bare "${client}"
{
  "hosts": [
    "${MDB}-svc.${NAMESPACE}.svc.cluster.local",
    "${MDB}.${MDB}-svc.${NAMESPACE}.svc.cluster.local"
  ],
  "CN": "${client}",
  "names": [
  {
    "C": "US",
    "ST": "New York",
    "L": "New York",
    "O": "cloud",
    "OU": "kubestore"
  }
  ],
  "key": {
    "algo": "rsa",
    "size": 4096
  }
}
EOF


    ## -> server.csr and server-key.pem

    cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: ${client}.${NAMESPACE}
spec:
  groups:
  - system:authenticated
  request: $(cat ${client}.csr | base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - server auth
  - client auth
EOF


    kubectl describe "csr/${client}.${NAMESPACE}"
    kubectl certificate approve ${client}.${NAMESPACE}

    kubectl get csr/${client}.${NAMESPACE} -o jsonpath='{.status.certificate}' \
        | base64 --decode > ${client}.crt

    cat ${client}.crt ${client}-key.pem > ${client}-full.pem
}

copy_into_pods() {
    file="${1}"
    members=$(kubectl -n ${NAMESPACE} get mdb/${MDB} -o jsonpath='{.spec.members}')
    members=$((members-1))

    for i in $(seq $members -1 0); do
        
        echo "kubectl cp $file \"${NAMESPACE}/${MDB}-$i:/mongodb-automation/\""
        kubectl cp $file "${NAMESPACE}/${MDB}-$i:/mongodb-automation/"
    done
}

clients="product-service-user"
for cert in $clients; do
    generate_cert_for_client "${cert}"
    # copy_into_pods "${cert}-full.pem"
done