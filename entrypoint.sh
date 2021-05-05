#!/usr/bin/env sh
set -euo pipefail

APP_WORKDIR=${APP_WORKDIR:-/}

DEPLOY_ROOT="/github/workspace/argo-deploy"
SOURCE_ROOT="/github/workspace/source"
VALUES_FILE="$(mktemp).yaml"
INGRESS_VALUES_FILE="$(mktemp).yaml"

printf "ACTION is '%s'\n" "$ACTION"
printf "DEPLOY is '%s'\n" "$DEPLOY"
printf "RELEASE is '%s'\n" "$RELEASE"

CHART=$( yq eval '.chart' ${BASE_PATH}/${APP}/app.yaml )
mkdir -p argo-deploy/${ATMOS_ENVIRONMENT}-${ATMOS_STACK}/argocd

if [[ -f "${BASE_PATH}/${APP}/env/default.yaml" ]] && [[ -f ${BASE_PATH}/${APP}/env/${ENVIRONMENT}.yaml ]]; then
  yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1) | {"values": .}' \
    ${BASE_PATH}/${APP}/env/default.yaml ${BASE_PATH}/${APP}/env/${ENVIRONMENT}.yaml > ${VALUES_FILE}
elif [[ -f "${BASE_PATH}/${APP}/env/default.yaml" ]]; then
  yq eval '{"values": .}' ${BASE_PATH}/${APP}/env/default.yaml > ${VALUES_FILE}
else
  yq eval -n '{"values": .}' > ${VALUES_FILE}
fi

cat >${INGRESS_VALUES_FILE} <<EOF
values:
  ingress:
    default:
      hosts:
        ${HOSTNAME}: /
      tls:
      - hosts:
        - ${HOSTNAME}
        secretName: ${APP}-cert
EOF

helm3 template ${RELEASE} ${BASE_PATH}/charts/argocd-application \
  --set targetNamespace=${TARGET_NAMESPACE} \
  --set path=${CHART} \
  --set repository=git@github.com:${REPOSITORY}.git \
  --set sha=${IMAGE_TAG} \
  --set image.repository=${IMAGE} \
  --set image.tag=${IMAGE_TAG} \
  --set createNamespace=true \
  --set ingress.default.hosts.example=test \
  --values ${VALUES_FILE} \
  --values ${INGRESS_VALUES_FILE} \
> argo-deploy/${ATMOS_ENVIRONMENT}-${ATMOS_STACK}/argocd/${RELEASE}.yaml

rm -f ${VALUES_FILE}
cat argo-deploy/${ATMOS_ENVIRONMENT}-${ATMOS_STACK}/argocd/${RELEASE}.yaml



exit $?
