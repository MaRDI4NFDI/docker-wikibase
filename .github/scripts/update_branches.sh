#!/bin/bash
# Set WMF_BRANCH and REL_BRANCH in clone_all.sh.
#
# WMF_BRANCH follows the version of Wikimedia's group 2 wikis. REL_BRANCH
# is the newest release branch older than that version which core and
# every extension cloned with ${REL_BRANCH} have.
set -euo pipefail

config=https://raw.githubusercontent.com/wikimedia/operations-mediawiki-config/master
fail() { echo "$*" >&2; exit 1; }

# The N of every REL1_N branch of a repository, one per line.
rel_branches() {
	git ls-remote --heads "$1" 'REL1_*' | sed -nE 's#.*refs/heads/REL1_([0-9]+)$#\1#p' | sort
}

repo_url() {
	case "$2" in
	"") echo "https://github.com/wikimedia/mediawiki-extensions-$1.git" ;;
	professionalwiki:*) echo "https://github.com/ProfessionalWiki/${2#professionalwiki:}.git" ;;
	*) echo "$2" ;;
	esac
}

current_wmf=$(sed -nE 's#^WMF_BRANCH=wmf/(.+)$#\1#p' clone_all.sh)
current_rel=$(sed -nE 's#^REL_BRANCH=(.+)$#\1#p' clone_all.sh)
[ -n "$current_wmf" ] && [ -n "$current_rel" ] || fail "no WMF_BRANCH or REL_BRANCH in clone_all.sh"

wiki=$(curl -fsS "$config/dblists/group2.dblist" | sed 's/#.*//' | awk 'NF { print $1; exit }')
[ -n "$wiki" ] || fail "group2.dblist lists no wiki"
wmf=$(curl -fsS "$config/wikiversions.json" | jq -er --arg wiki "$wiki" '.[$wiki]')
wmf=${wmf#php-}
[[ $wmf =~ ^1\.([0-9]+)\. ]] || fail "unexpected version $wmf"
minor=${BASH_REMATCH[1]}

candidates=$(rel_branches https://github.com/wikimedia/mediawiki.git | awk -v minor="$minor" '$1 < minor')
while IFS='|' read -r name _ override; do
	candidates=$(comm -12 <(echo "$candidates") <(rel_branches "$(repo_url "$name" "$override")"))
done < <(sed -nE 's/^ *"([^"|]+\|\$\{REL_BRANCH\}[^"]*)".*/\1/p' clone_all.sh)
newest=$(echo "$candidates" | sort -n | tail -n 1)
[ -n "$newest" ] || fail "no release branch below 1.$minor exists everywhere"
rel=REL1_$newest

echo "WMF_BRANCH: $current_wmf -> $wmf"
echo "REL_BRANCH: $current_rel -> $rel"

# Rewrite in place, so that clone_all.sh keeps its mode.
updated=$(sed -E -e "s#^WMF_BRANCH=.*#WMF_BRANCH=wmf/$wmf#" -e "s#^REL_BRANCH=.*#REL_BRANCH=$rel#" clone_all.sh)
printf '%s\n' "$updated" > clone_all.sh

if [ -n "${GITHUB_OUTPUT:-}" ]; then
	changed=false
	[ "$current_wmf $current_rel" = "$wmf $rel" ] || changed=true
	{
		echo "current_version=$current_wmf"
		echo "latest_version=$wmf"
		echo "current_rel=$current_rel"
		echo "latest_rel=$rel"
		echo "needs_update=$changed"
	} >> "$GITHUB_OUTPUT"
fi
