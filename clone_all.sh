#!/bin/bash
# cache-bust: 2026-03-31b
set -euxo pipefail

WMF_BRANCH=wmf/1.47.0-wmf.5
REL_BRANCH=REL1_45

GITHUB_WIKIMEDIA_EXTENSIONS=https://github.com/wikimedia/mediawiki-extensions
GITHUB_PROFESSIONALWIKI=https://github.com/ProfessionalWiki

git clone --depth=1 --single-branch -b "$WMF_BRANCH" \
  https://github.com/wikimedia/mediawiki.git mediawiki

EXTENSIONS=(
  # name|branch|repo-override
  # If branch is omitted, WMF_BRANCH is used.
  # If repo-override is omitted, Wikimedia's standard extension URL is used.
  "AdvancedSearch"
  "AWS|master|https://github.com/edwardspec/mediawiki-aws-s3.git"
  "ArticlePlaceholder"
  "Babel"
  "CirrusSearch"
  "Cite"
  "CiteThisPage"
  "cldr"
  "CodeEditor"
  "CodeMirror"
  "ConfirmEdit"
  "DataTransfer|$REL_BRANCH"
  "DisplayTitle|$REL_BRANCH"
  "Echo"
  "Elastica"
  "EntitySchema"
  "EventBus"
  "EventStreamConfig"
  "ExternalContent|master|professionalwiki:ExternalContent"
  "ExternalData|master"
  "Gadgets"
  "InputBox"
  "JsonConfig"
  "Lockdown|$REL_BRANCH"
  "MardiImport|main|https://github.com/MaRDI4NFDI/mediawiki-extension-MardiImport.git"
  "Math|master"
  "MathSearch|master"
  "MatomoAnalytics|main|https://github.com/miraheze/MatomoAnalytics.git"
  "MultimediaViewer"
  "Nuke"
  "OAuth"
  "OpenIDConnect|$REL_BRANCH"
  "PageForms|$REL_BRANCH"
  "PageImages"
  "ParserFunctions"
  "ParserMigration"
  "PdfHandler"
  "PluggableAuth|master"
  "Popups"
  "ProofreadPage"
  "ReplaceText|$REL_BRANCH"
  "Scribunto"
  "SemanticDrilldown|master|https://github.com/MaRDI4NFDI/SemanticDrilldown.git"
  "SemanticMediaWiki|master|https://github.com/SemanticMediaWiki/SemanticMediaWiki.git"
  "SPARQL|master|professionalwiki:SPARQL"
  "SyntaxHighlight_GeSHi"
  "TemplateStyles"
  "TextExtracts"
  "Thanks"
  "TimedMediaHandler"
  "UniversalLanguageSelector"
  "UrlGetParameters|$REL_BRANCH"
  "UserMerge|$REL_BRANCH"
  "Variables|$REL_BRANCH"
  "VisualEditor"
  "Widgets|$REL_BRANCH"
  "WikibaseCirrusSearch"
  "WikibaseExport|master|professionalwiki:WikibaseExport"
  "WikibaseFacetedSearch|master|professionalwiki:WikibaseFacetedSearch"
  # "WikibaseLexeme"
  "WikibaseLocalMedia|master|professionalwiki:WikibaseLocalMedia"
  "WikibaseManifest|$REL_BRANCH"
  "WikibaseMediaInfo"
  "WikibaseQualityConstraints"
  "WikiEditor"
  "YouTube|$REL_BRANCH"
)

resolve_repo() {
  local name=$1
  local repo=${2:-}

  case "$repo" in
    "")
      echo "${GITHUB_WIKIMEDIA_EXTENSIONS}-${name}.git"
      ;;
    professionalwiki:*)
      echo "${GITHUB_PROFESSIONALWIKI}/${repo#professionalwiki:}.git"
      ;;
    *)
      echo "$repo"
      ;;
  esac
}

clone_ext() {
  local name=$1
  local branch=${2:-$WMF_BRANCH}
  local repo

  repo=$(resolve_repo "$name" "${3:-}")

  echo "Cloning ${name} (${branch}) from ${repo}"

  git clone --depth=1 --recurse-submodules --single-branch -b "$branch" \
    "$repo" "mediawiki/extensions/$name"
}

for ext in "${EXTENSIONS[@]}"; do
  IFS='|' read -r name branch repo <<< "$ext"
  clone_ext "$name" "$branch" "$repo"
done

## Patch Wikibase
# cf. https://github.com/wmde/wikibase-release-pipeline/pull/753/files
# WORKAROUND for https://phabricator.wikimedia.org/T372458
# Take wikibase submodules from github as phabricator rate limits us
git clone --depth=1 https://github.com/wikimedia/mediawiki-extensions-Wikibase.git \
  --single-branch -b "$WMF_BRANCH" mediawiki/extensions/Wikibase

patch -d mediawiki/extensions/Wikibase -Np1 \
  < ./wikibase-submodules-from-github-instead-of-phabricator.patch

git -C mediawiki/extensions/Wikibase submodule update --init --recursive

# Workaround for https://phabricator.wikimedia.org/T388624
git -C mediawiki/extensions/DisplayTitle fetch \
  https://gerrit.wikimedia.org/r/mediawiki/extensions/DisplayTitle \
  refs/changes/48/1126048/1

git -C mediawiki/extensions/DisplayTitle checkout -b change-1126048 FETCH_HEAD

# Clone core and other skins
git clone --depth=1 https://github.com/wikimedia/mediawiki-skins-Vector \
  --single-branch -b "$WMF_BRANCH" mediawiki/skins/Vector

git clone --depth=1 https://github.com/ProfessionalWiki/chameleon.git \
  mediawiki/skins/chameleon

git clone --depth=1 https://github.com/ProfessionalWiki/MardiSkin.git \
  mediawiki/skins/MardiSkin

# Temporary dependency fix
rm -f mediawiki/extensions/DataTransfer/composer.json

sed -i 's/"psr\/http-message": "\^1"/"psr\/http-message": "^1 || ^2"/' \
  mediawiki/skins/chameleon/composer.json
