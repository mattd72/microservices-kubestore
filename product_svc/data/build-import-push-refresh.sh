REPO=docker.io/theburi
IMG=product-reviews-import
APP=product-reviews
IMAGE="${REPO}/${IMG}"
docker build -t ${IMAGE} --file Dockerfile.product-reviews-import .
docker push ${IMAGE}
sleep 5
kubectl delete -f ${APP}.yaml
sleep 20
kubectl create -f ${APP}.yaml

