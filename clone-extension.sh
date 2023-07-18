#!/usr/bin/env bash
EXTENSION=$1
BRANCH=$2

# Clone from gerrit by default. If it doesn't work, clone from github.
#git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/$EXTENSiON -b ${BRANCH} ${EXTENSION} \
#|| git clone https://github.com/wikimedia/mediawiki-extensions-${EXTENSION}.git -b ${BRANCH} ${EXTENSION}

git clone --depth=1 --recurse-submodules https://github.com/wikimedia/mediawiki-extensions-${EXTENSION}.git -b ${BRANCH} ${EXTENSION}
rm -rf ${EXTENSION}/.git
