REPO=docker.io/theburi
APP=filters-service
IMAGE="${REPO}/${APP}"
docker build -t ${IMAGE} .
docker push ${IMAGE}
kubectl delete -f ${APP}.yaml
sleep 20
kubectl create -f ${APP}.yaml

