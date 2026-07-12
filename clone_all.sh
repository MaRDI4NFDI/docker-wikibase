#!/bin/bash 
# cache-bust: 2026-07-09
set -euxo pipefail

WMF_BRANCH=wmf/1.47.0-wmf.10
REL_BRANCH=REL1_45

GITHUB_WIKIMEDIA_EXTENSIONS=https://github.com/wikimedia/mediawiki-extensions
GITHUB_PROFESSIONALWIKI=https://github.com/ProfessionalWiki

git clone --depth=1 --single-branch -b "${WMF_BRANCH}" https://github.com/wikimedia/mediawiki.git mediawiki

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
  "DataTransfer|${REL_BRANCH}"
  "DisplayTitle|${REL_BRANCH}"
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
  "Lockdown|${REL_BRANCH}"
  "MardiImport|main|https://github.com/MaRDI4NFDI/mediawiki-extension-MardiImport.git"
  "Math|master"
  "MathSearch|master"
  "MatomoAnalytics|main|https://github.com/miraheze/MatomoAnalytics.git"
  "MultimediaViewer"
  "Nuke"
  "OAuth"
  "OpenIDConnect|${REL_BRANCH}"
  "PageForms|${REL_BRANCH}"
  "PageImages"
  "ParserFunctions"
  "ParserMigration"
  "PdfHandler"
  "PluggableAuth|master"
  "Popups"
  "ProofreadPage"
  "ReplaceText|${REL_BRANCH}"
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
  "UrlGetParameters|${REL_BRANCH}"
  "UserMerge|${REL_BRANCH}"
  "Variables|${REL_BRANCH}"
  "VisualEditor"
  "Widgets|${REL_BRANCH}"
  "WikibaseCirrusSearch"
  "WikibaseExport|master|professionalwiki:WikibaseExport"
  "WikibaseFacetedSearch|master|professionalwiki:WikibaseFacetedSearch"
 # "WikibaseLexeme"
  "WikibaseLocalMedia|master|professionalwiki:WikibaseLocalMedia"
  "WikibaseManifest|${REL_BRANCH}"
  "WikibaseMediaInfo"
  "WikibaseQualityConstraints"
  "WikiEditor"
  "YouTube|${REL_BRANCH}"
)

resolve_repo() {
    REPO=${2:-}

    case "$REPO" in
        "")
            echo "${GITHUB_WIKIMEDIA_EXTENSIONS}-${1}.git"
            ;;
        professionalwiki:*)
            echo "${GITHUB_PROFESSIONALWIKI}/${REPO#professionalwiki:}.git"
            ;;
        *)
            echo "$REPO"
            ;;
    esac
}

add_submodule() {
    EXTENSION=$1
    BRANCH=${2:-$WMF_BRANCH}
    REPO_URL=$(resolve_repo "$EXTENSION" "${3:-}")
    
    # Execute the script with the extension and branch as arguments
    echo "Cloning ${EXTENSION} (${BRANCH}) from ${REPO_URL}"

    # Clone the repository using the provided URL
    git clone --depth=1 --recurse-submodules "$REPO_URL" --single-branch -b "$BRANCH" mediawiki/extensions/"$EXTENSION"
}

export -f add_submodule

# Run the submodule addition in parallel (degree 10)
# would require installation of additional package parallel
# parallel -j 10 add_submodule {1} {2} {3} ::: "${EXTENSIONS[@]}" | awk '{print $1, $2, $3}'

# Track background jobs
jobs=()

for ext in "${EXTENSIONS[@]}"
do
    IFS='|' read -r EXTENSION BRANCH REPO_URL <<< "$ext"

    # Run each add_submodule function in the background
    add_submodule "$EXTENSION" "$BRANCH" "$REPO_URL"
    
    #jobs+=($!)

    # Limit the number of background jobs to 1
    # if [[ ${#jobs[@]} -ge 1 ]]; then
        # Wait for the first background job to finish before continuing
    #    wait "${jobs[0]}"
        # Remove the completed job from the jobs array
    #    jobs=("${jobs[@]:1}")
    #fi
done

# Wait for any remaining background jobs to finish
wait



## Patch Wikibase
# cf. https://github.com/wmde/wikibase-release-pipeline/pull/753/files
# WORKAROUND for https://phabricator.wikimedia.org/T372458
# Take wikibase submodules from github as phabricator rate limits us
git clone --depth=1 https://github.com/wikimedia/mediawiki-extensions-Wikibase.git --single-branch -b ${WMF_BRANCH} mediawiki/extensions/Wikibase && \
    patch -d mediawiki/extensions/Wikibase -Np1 <./wikibase-submodules-from-github-instead-of-phabricator.patch && \
    git -C mediawiki/extensions/Wikibase submodule update --init --recursive    

# Workaround for https://phabricator.wikimedia.org/T388624
cd mediawiki/extensions/DisplayTitle
git fetch https://gerrit.wikimedia.org/r/mediawiki/extensions/DisplayTitle refs/changes/48/1126048/1 && git checkout -b change-1126048 FETCH_HEAD
cd ../../..

# Clone core and other skins
git clone --depth=1 https://github.com/wikimedia/mediawiki-skins-Vector -b ${WMF_BRANCH} mediawiki/skins/Vector
  # Other skins
git clone --depth=1 https://github.com/ProfessionalWiki/chameleon.git mediawiki/skins/chameleon 
git clone --depth=1 https://github.com/ProfessionalWiki/MardiSkin.git mediawiki/skins/MardiSkin

# Temporary dependency fix
rm -f mediawiki/extensions/DataTransfer/composer.json
sed -i 's/"psr\/http-message": "\^1"/"psr\/http-message": "^1 || ^2"/' mediawiki/skins/chameleon/composer.json
