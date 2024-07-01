#!/bin/sh

echo 'const g_versions = ['
(
	# one version for each directory in "$1"
	find $1 -mindepth 1 -maxdepth 1 -type d -printf "%f\n"

	# optionally use git for versions
	#git rev-parse --abbrev-ref HEAD # branch name of HEAD
	#git tag
) | awk '{ printf("  \"%s\",\n", $1); }'
echo ']'
