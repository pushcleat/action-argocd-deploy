#!/usr/bin/env sh

set -euo pipefail

APP_WORKDIR=${APP_WORKDIR:-/}

DESTINATION_DIR=${DESTINATION_DIR:-/github/workspace/argo-deploy}
VALUES_FILE="$(mktemp).yaml"

mkdir -p ${DESTINATION_DIR}/${STACK}/argocd

echo "${VALUES}" | yq eval '{"values": .}' - > ${VALUES_FILE}

helm3 template ${RELEASE} ${APP_WORKDIR}/argocd-application \
  --set targetNamespace=${NAMESPACE} \
  --set path=${CHART} \
  --set repository=git@github.com:${REPOSITORY}.git \
  --set sha=${IMAGE_TAG} \
  --set image.repository=${IMAGE} \
  --set image.tag=${IMAGE_TAG} \
  --set createNamespace=true \
  --values ${VALUES_FILE} \
> ${DESTINATION_DIR}/${STACK}/argocd/${RELEASE}.yaml

mkdir -p test-action-argocd-deploy
cd test-action-argocd-deploy

cat ${DESTINATION_DIR}/${STACK}/argocd/${RELEASE}.yaml > file1.txt

git init
git config --global user.name 'kollyuchka'
git config --global user.email 'kollyuchkaola@gmail.com'
git add .
git commit -m "first commit"
git branch -M main
git remote add origin git@github.com:${DESTINATION_REPOSITORY}
git push -u origin main
rm -f ${VALUES_FILE}

exit $?
