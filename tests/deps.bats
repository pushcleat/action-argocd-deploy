#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

@test "aws exists" {
	run aws --version
	assert_success
}

