```
                      _            _                                 _          
  _ __  _ __ ___   __| |_   _  ___| |_ ___       ___  ___ _ ____   _(_) ___ ___ 
 | '_ \| '__/ _ \ / _` | | | |/ __| __/ __|_____/ __|/ _ \ '__\ \ / / |/ __/ _ \
 | |_) | | | (_) | (_| | |_| | (__| |_\__ \_____\__ \  __/ |   \ V /| | (_|  __/
 | .__/|_|  \___/ \__,_|\__,_|\___|\__|___/     |___/\___|_|    \_/ |_|\___\___|
 |_|                                                                            
```
---
A simple basic Kubernetes-ready, HTTP based microservice which can 
query and update a collection of products in MongoDB. The service 
is implemented in python and uses:
- Flask
- pymongo
- python-kubernetes

Authentication uses standard username:password HTTP digest.

There is a single default route ``/`` which accepts, `GET`, `POST`, & `DELETE` 
`HTTP` Methods. Refer to app/app.py for the API reference and examples.

This sample software is for educational purposes and not meant for 
production systems. 

## Getting started

```bash
$unzip product-reviews-kube.zip
$kubectl run -it mongo:rc :wq

$kubectl run -it mongo:rc mongoimport --host <HOST> -d products -c reviews

```bash
$cd products-service

# Generate Certificate 
# Kuberenetes x509 CSR  https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/
$bash ./user/gencert.sh

# Create file with base64 encoded secrete 
$cat user/product-service-user-full.pem  | base64 | pbcopy

# paste cert into user/user_secret.yaml
# Create Secret
$kubectl apply -f user/user_secret.yaml

# Create MongoDB User
$kubectl apply -f user/mongodbuser-products.yml

# Create Product Service Deployment
$kubectl apply -f products-service.yaml



# Get User name from x509 <rfc2253-subject>
openssl x509 -noout -subject -in <file.pem>


Add uri mongodb+srv://product-service-2-mdb-svc.mongodb.svc.cluster.local

# List nodes and pods running in each pod 
$kubectl get pod -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName

