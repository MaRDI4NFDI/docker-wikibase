# docker-wikibase
MediaWiki/Wikibase Docker Image 
* Built from the official latest MediaWiki docker image
* With standard and MaRDI extensions preinstalled

* Staging image is built automatically on push to main or on merging a PR
* Production image is only built when pushing a tag

# Description of the Dockerfile

## 1. Fetcher Stage (Ubuntu Container)
- Creates an Ubuntu container with git and curl
- Downloads MediaWiki extensions from specified source repositories using `clone_all.sh`
- Removes git artifacts (.git folders) to clean up the build

## 2. Composer Stage (MediaWiki Container)
- Uses the official MediaWiki Docker container as base
- Places downloaded repositories from the fetcher into MediaWiki's extensions folder
- Runs `composer install` to execute extension-specific installation steps

## 3. Final Image Creation (MaRDI-Wikibase)
- Creates the final container image based on MediaWiki
- Installs prerequisite packages
- Copies MediaWiki content (including extensions) from the composer stage
- Adds additional data and configuration files
- Creates necessary endpoints
- Copies settings templates to the final container image

# Description of Localsettings.d directory

  1. `base`: Contains all the extension configuration that is shared both in production and staging
  2. `staging`: Contains configuration files that are only installed in the staging image
  2. `production`: Contains configuration files that are only installed in the production image

# Create tag and new release

## Option 1

Manually trigger the **Create Release Tag** action.

## Option 2

* Create and push a new signed tag with the newer version to trigger a production release:
```
git tag -s <tag_version>
git push origin <tag_version>
```

* Manually create the release through the Github UI from the corresponding tag
# Overview of the Shell-scripts 

|shellscript  | description                                      |
| ----------- | ------------------------------------------------ |
|clone-all.sh|clone all extensions from github with the correct branch|
|wait-for-it.sh|wait for ports in other containers to be actually available (not the same as waiting that the container has started)|
|entrypoint.sh|Entrypoint of the container, installs the wiki's maintenance/install scripts|
|extra-install.sh|creates elastic search index and OAuth settings for Quickstatements|

# Adding extensions
To install and activate a new extension you have to:
* Add it to the `clone_all.sh` script in the `EXTENSIONS` array:

`"AdvancedSearch ${WMF_BRANCH} https://github.com/wikimedia/mediawiki-extensions-AdvancedSearch.git"`

* Activate and configure it as required with the corresponding `php` file under `base`, `staging` or `production` in the `LocalSettings.d` directory.

# Build manually

`docker build -t ghcr.io/mardi4nfdi/docker-wikibase:main .`

# Creating a stable tag

```
docker pull ghcr.io/mardi4nfdi/docker-wikibase:main
docker tag ghcr.io/mardi4nfdi/docker-wikibase:main ghcr.io/mardi4nfdi/docker-wikibase:stable
docker push ghcr.io/mardi4nfdi/docker-wikibase:stable
