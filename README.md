# docker-wikibase
Wikibase Docker image 
* built from from official mediawiki 1.35 Docker image
* with standard and MaRDI extensions preinstalled

The image is built by CI automatically on push to main

To build manually: `docker build -t ghcr.io/mardi4nfdi/docker-wikibase:main .`

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
