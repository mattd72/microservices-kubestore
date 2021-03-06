#!/usr/bin/env bash


NAMESPACE="mongodb"
MDB="product-service-2-mdb"

# rfc2253-subject

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
    sleep 5
    kubectl certificate approve ${client}.${NAMESPACE}
    sleep 5
    kubectl get csr/${client}.${NAMESPACE} -o jsonpath='{.status.certificate}' \
        | base64 --decode > ${client}.crt

    cat ${client}.crt ${client}-key.pem > ${client}-full.pem
}


clients="product-service-user"
for cert in $clients; do
    generate_cert_for_client "${cert}"
done