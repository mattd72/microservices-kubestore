* permanently save the namespace for all subsequent kubectl commands in that context.
kubectl config set-context <context> --namespace=mongodb

* Apply mongodb CRD
    apply -f ../kubesetup/crds.yaml 

* Create mongodb Operator to watch namespase mongodb
     apply -f ../kubesetup/mongodb-enterprise.yaml 



