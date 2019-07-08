https://dev.to/ianknighton/deploying-a-microservice-on-azure-kubernetes-with-lets-encrypt-4eon

https://docs.microsoft.com/en-us/azure/aks/ingress-tls

* Install helm and tiller

* apply helm-rbac.yaml to enable tiller service account

* helm init --service-account tiller

* Create an Ingress Controller
helm install stable/nginx-ingress --namespace kube-system --set controller.replicaCount=2
This process will create an IP address for the cluster, we'll need that going forward.

To find the public IP address:

kubectl get service -l app=nginx-ingress --namespace kube-system
From the output of that command, you will need to EXTENRAL-IP of the LoadBalancer service.

NAME                                              TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)                      AGE
invincible-toucan-nginx-ingress-controller        LoadBalancer   10.0.186.72   192.167.15.243   80:30947/TCP,443:32654/TCP   2d
invincible-toucan-nginx-ingress-default-backend   ClusterIP      10.0.173.78   <none>           80/TCP 

* Install Cert-Manager
(Quick edit: It appears that there may be an issue with Cert-Manager version 0.6. This documentation was written against version 0.5.2, so I updated this command to specify the version.)

helm install stable/cert-manager --version 0.5.2 --namespace kube-system --set ingressShim.defaultIssuerName=letsencrypt-prod --set ingressShim.defaultIssuerKind=ClusterIssuer

* Create a Cluster Issuer cluster-issuer.yaml
Create a file in your working directory called cluster-issuer.yaml.

kubectl apply -f cluster-issuer.yaml

* Add FQDN to AKS - DNS route
 Get external IP of ingress (prev step) and add it to networkconfig.sh as well as preffered DNS name
 Run networkconfig.sh
 look for DNSName.Zone..cloudapp.azure.com

* Create a Certificate Object
Create a file in your working directory called certificate.yaml and add the following information.

apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: tls-secret
spec:
  secretName: tls-secret
  dnsNames:
  - <url>
  acme:
    config:
    - http01:
        ingressClass: nginx
      domains:
      - <url>
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
Use kubectl to apply this certificate.

kubectl apply -f certificates.yaml

* Create an Ingress Route
Create a file called ingress-route.yaml and add the following:

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    certmanager.k8s.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  tls:
  - hosts:
    - <url>
    secretName: tls-secret
  rules:
  - host: <url>
    http:
      paths:
      - path: /
        backend:
          serviceName: <service-name>
          servicePort: 3000
Apply the change with kubectl.

kubectl apply -f ingress-route.yaml

