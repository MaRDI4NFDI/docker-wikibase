#!/bin/bash 
WMF_BRANCH=wmf/1.44.0-wmf.21
REL_BRANCH=REL1_43

git clone --depth=1 --single-branch -b "${WMF_BRANCH}" https://github.com/wikimedia/mediawiki.git mediawiki

EXTENSIONS=(
  "AdvancedSearch ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-AdvancedSearch.git"
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
  # Wokraround for https://phabricator.wikimedia.org/T388624
  "ExternalData master https://github.com/wikimedia/mediawiki-extensions-ExternalData.git"
  "Gadgets ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-Gadgets.git"
  "Graph ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-Graph.git"
  "InputBox ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-InputBox.git"
  "JsonConfig ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-JsonConfig.git"
  "LinkedWiki master https://github.com/wikimedia/mediawiki-extensions-LinkedWiki.git"
  "Lockdown ${REL_BRANCH} https://github.com/wikimedia/mediawiki-extensions-Lockdown.git"
  "Math master https://github.com/wikimedia/mediawiki-extensions-Math.git"
  "MathSearch master https://github.com/wikimedia/mediawiki-extensions-MathSearch.git"
  "MultimediaViewer ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-MultimediaViewer.git"
  "Nuke ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-Nuke.git"
  "OAuth ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-OAuth.git"
  "OpenIDConnect ${REL_BRANCH} https://github.com/wikimedia/mediawiki-extensions-OpenIDConnect.git"
  "PageForms ${REL_BRANCH} https://github.com/wikimedia/mediawiki-extensions-PageForms.git"
  "PageImages ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-PageImages.git"
  "ParserFunctions ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-ParserFunctions.git"
  "PdfHandler ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-PdfHandler.git"
  # Workaround for https://phabricator.wikimedia.org/T388624
  "PluggableAuth master https://github.com/wikimedia/mediawiki-extensions-PluggableAuth.git"
  "Popups ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-Popups.git"
  "ReplaceText ${REL_BRANCH} https://github.com/wikimedia/mediawiki-extensions-ReplaceText.git"
  "Scribunto ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-Scribunto.git"
  "SyntaxHighlight_GeSHi ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-SyntaxHighlight_GeSHi.git"
  "TemplateStyles ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-TemplateStyles.git"
  "TextExtracts ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-TextExtracts.git"
  "Thanks ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-Thanks.git"
  "TimedMediaHandler ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-TimedMediaHandler.git"
  "UniversalLanguageSelector ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-UniversalLanguageSelector.git"
  "UrlGetParameters ${REL_BRANCH} https://github.com/wikimedia/mediawiki-extensions-UrlGetParameters.git"
  "UserMerge ${REL_BRANCH} https://github.com/wikimedia/mediawiki-extensions-UserMerge.git"
  "VisualEditor ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-VisualEditor.git"
  "Widgets ${REL_BRANCH} https://github.com/wikimedia/mediawiki-extensions-Widgets.git"
  "WikibaseCirrusSearch ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-WikibaseCirrusSearch.git"
  "WikibaseLexeme ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-WikibaseLexeme.git"
  "WikibaseManifest ${REL_BRANCH} https://github.com/wikimedia/mediawiki-extensions-WikibaseManifest.git"
  "WikibaseQualityConstraints ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-WikibaseQualityConstraints.git"
  "WikiEditor ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-WikiEditor.git"
  "YouTube ${REL_BRANCH} https://github.com/wikimedia/mediawiki-extensions-YouTube.git"
  # Additional repositories (integrated into the main loop)
  "WikibaseLocalMedia master https://github.com/ProfessionalWiki/WikibaseLocalMedia.git"
  "WikibaseExport master https://github.com/ProfessionalWiki/WikibaseExport.git"
  "ExternalContent master https://github.com/ProfessionalWiki/ExternalContent.git"
  "SPARQL master https://github.com/ProfessionalWiki/SPARQL.git"
  "WikibaseFacetedSearch master https://github.com/MaRDI4NFDI/WikibaseFacetedSearch.git"
  "MatomoAnalytics master https://github.com/MaRDI4NFDI/MatomoAnalytics.git"
  "SemanticMediaWiki master https://github.com/SemanticMediaWiki/SemanticMediaWiki.git"
  "SemanticDrilldown master https://github.com/MaRDI4NFDI/SemanticDrilldown.git"
)

for ext in "${EXTENSIONS[@]}"
do
    # Split the extension name, branch, and URL using space as delimiter
    EXTENSION=$(echo "$ext" | awk '{print $1}')
    BRANCH=$(echo "$ext" | awk '{print $2}')
    REPO_URL=$(echo "$ext" | awk '{print $3}')
    
    # Execute the script with the extension and branch as arguments
    echo "Cloning ${EXTENSION} (${BRANCH}) from ${REPO_URL}"

    # Clone the repository using the provided URL
    git clone --depth=1 --recurse-submodules "$REPO_URL" --single-branch -b "$BRANCH" mediawiki/extensions/"$EXTENSION"
done

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
cd ../LinkedWiki
git fetch https://gerrit.wikimedia.org/r/mediawiki/extensions/LinkedWiki refs/changes/39/1131939/1 && git checkout -b change-1131939 FETCH_HEAD
cd ../../..

# Clone core and other skins
git clone --depth=1 https://github.com/wikimedia/mediawiki-skins-Vector -b ${WMF_BRANCH} mediawiki/skins/Vector
  # Other skins
# see https://github.com/ProfessionalWiki/chameleon/pull/462  
git clone --depth=1 https://github.com/physikerwelt/chameleon.git -b patch-1 mediawiki/skins/chameleon 
git clone --depth=1 https://github.com/ProfessionalWiki/MardiSkin.git mediawiki/skins/MardiSkin
