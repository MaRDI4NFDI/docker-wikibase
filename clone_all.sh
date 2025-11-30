#!/bin/bash 
set -euxo pipefail

WMF_BRANCH=wmf/1.46.0-wmf.4
REL_BRANCH=REL1_45

git clone --depth=1 --single-branch -b "${WMF_BRANCH}" https://github.com/wikimedia/mediawiki.git mediawiki

EXTENSIONS=(
  "AdvancedSearch ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-AdvancedSearch.git"
  "AWS master https://github.com/edwardspec/mediawiki-aws-s3.git"
  "ArticlePlaceholder ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-ArticlePlaceholder.git"
  "Babel ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-Babel.git"
  "CirrusSearch ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-CirrusSearch.git"
  "Cite ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-Cite.git"
  "CiteThisPage ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-CiteThisPage.git"
  "cldr ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-cldr.git"
  "CodeEditor ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-CodeEditor.git"
  "CodeMirror ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-CodeMirror.git"
  "ConfirmEdit ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-ConfirmEdit.git"
  "DataTransfer ${REL_BRANCH} https://github.com/wikimedia/mediawiki-extensions-DataTransfer.git"
  "DisplayTitle ${REL_BRANCH} https://github.com/wikimedia/mediawiki-extensions-DisplayTitle.git"
  "Echo ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-Echo.git"
  "Elastica ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-Elastica.git"
  "EntitySchema ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-EntitySchema.git"
  "ExternalContent master https://github.com/ProfessionalWiki/ExternalContent.git"
  "ExternalData master https://github.com/wikimedia/mediawiki-extensions-ExternalData.git"
  "Gadgets ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-Gadgets.git"
  "InputBox ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-InputBox.git"
  "JsonConfig ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-JsonConfig.git"
  "Lockdown ${REL_BRANCH} https://github.com/wikimedia/mediawiki-extensions-Lockdown.git"
  "Math master https://github.com/wikimedia/mediawiki-extensions-Math.git"
  "MathSearch master https://github.com/wikimedia/mediawiki-extensions-MathSearch.git"
  "MatomoAnalytics main https://github.com/miraheze/MatomoAnalytics.git"
  "MultimediaViewer ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-MultimediaViewer.git"
  "Nuke ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-Nuke.git"
  "OAuth wmf/1.45.0-wmf.25 https://github.com/wikimedia/mediawiki-extensions-OAuth.git"
  "OpenIDConnect ${REL_BRANCH} https://github.com/wikimedia/mediawiki-extensions-OpenIDConnect.git"
  "PageForms ${REL_BRANCH} https://github.com/wikimedia/mediawiki-extensions-PageForms.git"
  "PageImages ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-PageImages.git"
  "ParserFunctions ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-ParserFunctions.git"
  "PdfHandler ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-PdfHandler.git"
  "PluggableAuth master https://github.com/wikimedia/mediawiki-extensions-PluggableAuth.git"
  "Popups ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-Popups.git"
  "ProofreadPage ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-ProofreadPage.git"
  "ReplaceText ${REL_BRANCH} https://github.com/wikimedia/mediawiki-extensions-ReplaceText.git"
  "Scribunto ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-Scribunto.git"
  "SemanticDrilldown master https://github.com/MaRDI4NFDI/SemanticDrilldown.git"
  "SemanticMediaWiki master https://github.com/SemanticMediaWiki/SemanticMediaWiki.git"
  "SPARQL master https://github.com/ProfessionalWiki/SPARQL.git"
  "SyntaxHighlight_GeSHi ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-SyntaxHighlight_GeSHi.git"
  "TemplateStyles ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-TemplateStyles.git"
  "TextExtracts ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-TextExtracts.git"
  "Thanks ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-Thanks.git"
  "TimedMediaHandler ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-TimedMediaHandler.git"
  "UniversalLanguageSelector ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-UniversalLanguageSelector.git"
  "UrlGetParameters ${REL_BRANCH} https://github.com/wikimedia/mediawiki-extensions-UrlGetParameters.git"
  "UserMerge ${REL_BRANCH} https://github.com/wikimedia/mediawiki-extensions-UserMerge.git"
  "Variables ${REL_BRANCH} https://github.com/wikimedia/mediawiki-extensions-Variables.git"
  "VisualEditor ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-VisualEditor.git"
  "Widgets ${REL_BRANCH} https://github.com/wikimedia/mediawiki-extensions-Widgets.git"
  "WikibaseCirrusSearch ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-WikibaseCirrusSearch.git"
  "WikibaseExport master https://github.com/ProfessionalWiki/WikibaseExport.git"
  "WikibaseFacetedSearch master https://github.com/ProfessionalWiki/WikibaseFacetedSearch.git"
 # "WikibaseLexeme ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-WikibaseLexeme.git"
  "WikibaseLocalMedia master https://github.com/ProfessionalWiki/WikibaseLocalMedia.git"
  "WikibaseManifest ${REL_BRANCH} https://github.com/wikimedia/mediawiki-extensions-WikibaseManifest.git"
  "WikibaseMediaInfo ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-WikibaseMediaInfo.git"
  "WikibaseQualityConstraints ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-WikibaseQualityConstraints.git"
  "WikiEditor ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-WikiEditor.git"
  "YouTube ${REL_BRANCH} https://github.com/wikimedia/mediawiki-extensions-YouTube.git"
)

add_submodule() {
    EXTENSION=$1
    BRANCH=$2
    REPO_URL=$3
    
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
    # Split the extension name, branch, and URL using space as delimiter
    EXTENSION=$(echo "$ext" | awk '{print $1}')
    BRANCH=$(echo "$ext" | awk '{print $2}')
    REPO_URL=$(echo "$ext" | awk '{print $3}')

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
