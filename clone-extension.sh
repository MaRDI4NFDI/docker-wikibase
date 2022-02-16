#!/usr/bin/env bash
EXTENSION=$1
BRANCH=$2

git clone https://github.com/wikimedia/mediawiki-extensions-${EXTENSION}.git -b ${BRANCH} ${EXTENSION}
rm -rf ${EXTENSION}/.git
