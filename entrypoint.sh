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

rm -f ${VALUES_FILE}

exit $?
