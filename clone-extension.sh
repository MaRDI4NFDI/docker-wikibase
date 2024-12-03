#!/usr/bin/env bash
EXTENSION=$1
BRANCH=$2

git clone --depth=1 --recurse-submodules https://github.com/wikimedia/mediawiki-extensions-${EXTENSION}.git --single-branch -b ${BRANCH} ${EXTENSION}
# rm -rf ${EXTENSION}/.git/objects
