# to float the v1 release to a specific tag, run:
# just float-v1-release-tag v1.X
# where v1.X is a tag which already exists
float-v1-release-tag tag:
	#!/usr/bin/env bash
	set -euxo pipefail
	git tag -d v1
	git fetch --tags
	SHA=$(git rev-parse {{tag}})
	echo "$SHA"
	gh api -X PATCH repos/twopow/auto-version-action/git/refs/tags/v1 -f sha="$SHA" -F force=true
