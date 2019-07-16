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
$unzip consumer-reviews-of-amazon-products.zip
$kubectl run -it mongo:rc :wq

$kubectl run -it mongo:rc mongoimport --host <HOST> -d products -c reviews
```bash
$git clone https://github.com/jasonmimick/products-service
$cd products-service
$kubectl create secret PRODUCTS_SERVICE_MONGODB_URI "mongodb+srv://products-db-src.cluster.local"

$kubectl create secret generic product-service-import-host --from-literal="MONGODB_URI=mongodb+srv://product-service-mdb.cluster.local"
$kubectl apply -f kubernetes/products-service.yaml

Kuberenetes x509 CSR  https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/

Get User name from x509
openssl x509 -noout -subject -in <file.pem>

Create file with base64 encoded secrete 
$cat user/product-service-user-full.pem  | base64 | pbcopy

Add uri mongodb+srv://product-service-2-mdb-svc.mongodb.svc.cluster.local



