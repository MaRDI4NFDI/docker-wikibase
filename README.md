# docker-wikibase
Wikibase Docker image 
* built from official latest mediawiki Docker image
* with standard and MaRDI extensions preinstalled

The image is built by CI automatically on push to main.
The built takes about 10 minutes.
The new image will be deployed to production automatically.
Please test that the new image works in production by comparing the hash of the production and the new build image.

To build manually: `docker build -t ghcr.io/mardi4nfdi/docker-wikibase:main .`

# Description of the Dockerfile
 The docker-wikibase build is realised by multiple containers. At first an ubuntu-container is created which has git and curl which downloads mediawiki-extensions from the specified source repositories (fetcher). Then git-artifacts (.git folders) are removed. The collector is a mediawiki-docker-container, the downloaded repositories from the fetcher are now placed in the extensions folder of mediawiki in the collectors filesystem. The composer copies the mediawiki-data (including the custom extensions) and calls composer install. Composer install launches the specific installation steps of the extensions which are usually defined in the composer.json files Finally the container-image for mardi-wikibase is created on base of mediawiki, prerequisited packages are installed, then the mediawiki-content is created from the mediawiki-files (which include the extensions) from composer, additional data and configuration is copied to the mardi-wikibase, endpoints are created. Several templates for settings are copied to the final container-image, the actual settings when using the container are defined in portal-compose, in the files here. 

# Description of Localsettings.php Files 

  1. LocalSettings.php.template is the original Localsettings from the official mediawiki.
  2. LocalSettings.php.wikibase-bundle.template is the original Localsettings from the wikibase docker bundle.
  3. LocalSettings.php.mardi.template activates the extensions required by the MaRDI portal

2 and 3 are concatted to the final LocalSettings in shared folder in entrypoint.sh 

**Note**: edits of `LocalSettings.php.*template` files are **not** deployed on a running system, but are only considered on initialization. Fixes must therefore be carried out manually on the production system.

# Overview of the Shell-scripts 

|shellscript  | description                                      |
| ----------- | ------------------------------------------------ |
|clone-extension.sh|clone an extension from github with the correct branch|
|wait-for-it.sh|wait for ports in other containers to be actually available (not the same as waiting that the container has started)|
|entrypoint.sh|Entrypoint of the container, installs the wiki's maintenance/install scripts|
|extra-install.sh|creates elastic search index and OAuth settings for Quickstatements|
|extra-entrypoint-run-first.sh|Creates the elastic search index, after calling wait-for-it|

## Adding extensions
To add a "standard" extension (an extension that will not be developed by MaRDI)
you have to edit the Dockerfile. The Dockerfile builds 4 images called "fetcher", "collector", "composer" 
and the final image that will be tagged as "https://github.com/MaRDI4NFDI/docker-wikibase" 
* In "fetcher", 
> you can either download the extension tar.gz archive or clone it using git. 
> You might want to clone the 1_35 branch if applicable. When cloning, you might want to delete the .git folder.
* In "collector", 
> copy the extension source code to "/var/www/html/extensions/XXX". 
> Note that the name of the extension is required in the destination (the XXX part) as Docker COPY behaves differently than the cp command.
* "composer" will run "composer install" in "/var/www/html/" so no changes required
* To enable the extension, activate it in one of the LocalSettings template files. 
> Note that "$" should be replaced by "${DOLLAR}" for some [exotic reason](https://phabricator.wikimedia.org/T264007).

To add a "custom" extension, you can always mount it in the docker-compose file of the portal.
