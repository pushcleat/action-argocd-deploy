#!/usr/bin/env bats
load '/usr/local/lib/bats/load.bash'

setup() {
  TEST_TEMP_DIR="$(temp_make)"
}

@test "pack action" {
	export DESTINATION_DIR=${TEST_TEMP_DIR}/result
	export DESTINATION_REPOSITORY=pushcleat/test-action-argocd-deploy
	export RELEASE=test-release
	export STACK=ue1-staging
	export NAMESPACE=test-namespace
	export CHART="./chart"
	export REPOSITORY=test-repository
	export IMAGE=nginx
	export IMAGE_TAG=latest
	export VALUES='test: "value"'

  run	${APP_WORKDIR}/entrypoint.sh

  assert_output ""
  assert_success

  assert_file_exist ${TEST_TEMP_DIR}/result/ue1-staging/argocd/test-release.yaml

  run diff ${TEST_TEMP_DIR}/result/ue1-staging/argocd/test-release.yaml ${BATS_TEST_DIRNAME}/fixtures/expected/release.yml

  assert_output ""
  assert_success

  run git clone https://github.com/${DESTINATION_REPOSITORY} ${TEST_TEMP_DIR}/result-repo

    assert_file_exist ${TEST_TEMP_DIR}/result-repo/ue1-staging/argocd/test-release.yaml

    run diff ${TEST_TEMP_DIR}/result-repo/ue1-staging/argocd/test-release.yaml ${BATS_TEST_DIRNAME}/fixtures/expected/release.yml

    assert_output ""
    assert_success



}

teardown() {
  temp_del "$TEST_TEMP_DIR"
}