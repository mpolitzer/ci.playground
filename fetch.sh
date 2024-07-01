#!/bin/sh
# download
# sha512sum
# extract

# 1. url
# 2. sha512sum
# 3. dst

set -e
T=$(mktemp)
trap 'rm $T' EXIT

# don't use `wget` progress options, alpine doesn't have them
# don't use `tar` "--one-top-level", alpine doesn't have it
wget -O $T $1 && echo "$2  $T" | sha512sum -c
mkdir -p $3 && tar xf $T --strip-components=1 -C $3
