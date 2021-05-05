#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

@test "jsonnet exists" {
	run jsonnet --version
	assert_success
}

@test "yq exists" {
	run yq --version
	assert_success
}

