#!/usr/bin/env bats
load '/usr/local/lib/bats/load.bash'

setup() {
  TEST_TEMP_DIR="$(temp_make)"
}

@test "pack action" {
	mkdir -p ${TEST_TEMP_DIR}/source
  cp ${BATS_TEST_DIRNAME}/fixtures/action/* ${TEST_TEMP_DIR}/source/

	export SOURCE_DIR=${TEST_TEMP_DIR}/source
	export DESTINATION_DIR=${TEST_TEMP_DIR}/result
	export IMAGE="nginx:latest"

  run ${APP_WORKDIR}/entrypoint.sh

  assert_output ""
  assert_success
  assert_file_exist ${TEST_TEMP_DIR}/result/action.yml
  run diff ${TEST_TEMP_DIR}/result/action.yml ${BATS_TEST_DIRNAME}/fixtures/expected/action.yml
  assert_output ""
  assert_success
}

teardown() {
  temp_del "$TEST_TEMP_DIR"
}