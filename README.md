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

# Local Building and Execution with Docker Bake

This repository utilizes a centralized `docker-bake.hcl` configuration. This architecture enforces strict build-time dependencies directly within the Docker build engine (Buildx). Downstream targets like `apache-assets` and `wikibase-dev` securely read compiled image metadata right from your local cache memory. This completely blocks network lookups to GitHub Packages (`ghcr.io`) and prevents local image or architecture conflicts.

### 1. Build All Images Locally
To compile the entire multi-container stack (`wikibase`, `apache`, `apache-assets`, and `wikibase-dev`) at once, run:
```bash
docker buildx bake --load
```
*Note: The `--load` flag ensures that the compiled image layers are exported directly out of the build cache into your local standard Docker Desktop daemon list.*

### 2. Build Specific Service Targets
You can compile individual image variations by passing their defined target keys:

* **Build the development image only:**
  ```bash
  docker buildx bake wikibase-dev --load
  ```
* **Build the assets proxy configuration only:**
  ```bash
  docker buildx bake apache-assets --load
  ```

### 3. Testing Specific Production/PR Tags Locally (`IMAGE_TAG`)
The configuration reads the environment dynamically. If you want to simulate a specific release version (e.g., `1.23.4`) or pull request layout locally without running the online GitHub Actions pipeline, prefix your command with the `IMAGE_TAG` variable:

```bash
IMAGE_TAG=1.23.4 docker buildx bake --load
```

# Pushing Local ARM64 Builds to GHCR (Manual)

If you need to share your locally compiled Apple Silicon (`arm64`) images on GitHub Packages manually, you can bake and push them using the `IMAGE_TAG` environment variable.

### 1. Authenticate with GHCR via GitHub CLI (`gh`)
```bash
gh auth login --scopes write:packages
gh auth token | docker login ghcr.io -u "\$(gh api user --jq .login)" --password-stdin
```

### 2. Build and Push All 4 Variants with an ARM64 Tag
```bash
export IMAGE_TAG="1.47.9-arm64"
docker buildx bake --load
docker push "ghcr.io/mardi4nfdi/wikibase:${IMAGE_TAG}"
docker push "ghcr.io/mardi4nfdi/apache:${IMAGE_TAG}"
docker push "ghcr.io/mardi4nfdi/apache-assets:${IMAGE_TAG}"
docker push "ghcr.io/mardi4nfdi/wikibase-dev:${IMAGE_TAG}"
```
