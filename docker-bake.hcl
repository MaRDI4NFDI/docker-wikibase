variable "IMAGE_TAG" {
  default = "latest"
}

group "default" {
  targets = ["wikibase", "apache", "apache-assets", "wikibase-dev"]
}

# ==========================================
# 1. CORE WIKIBASE IMAGE
# ==========================================
target "wikibase" {
  context    = "."
  dockerfile = "Dockerfile"
  tags       = ["ghcr.io/mardi4nfdi/wikibase:${IMAGE_TAG}"]
  labels = {
    "org.opencontainers.image.title"       = "Wikibase image"
    "org.opencontainers.image.description" = "Mediawiki/Wikibase image for the MaRDI portal"
    "org.opencontainers.image.source"      = "https://github.com/MaRDI4NFDI/docker-wikibase"
  }
}

# ==========================================
# 2. APACHE REVERSE PROXY
# ==========================================
target "apache" {
  context    = "./apache"
  dockerfile = "Dockerfile"
  tags       = ["ghcr.io/mardi4nfdi/apache:${IMAGE_TAG}"]
  labels = {
    "org.opencontainers.image.title"       = "Apache Proxy"
    "org.opencontainers.image.description" = "Apache reverse proxy for Mediawiki/Wikibase"
    "org.opencontainers.image.source"      = "https://github.com/MaRDI4NFDI/docker-wikibase/tree/main/apache"
  }
}

# ==========================================
# 3. APACHE WITH STATIC ASSETS
# ==========================================
target "apache-assets" {
  context    = "./apache_assets"
  dockerfile = "Dockerfile"
  tags       = ["ghcr.io/mardi4nfdi/apache-assets:${IMAGE_TAG}"]

  depends_on = ["wikibase", "apache"]

  contexts = {
    wikibase-local = "target:wikibase"
    apache-local   = "target:apache"
  }

  labels = {
    "org.opencontainers.image.title"       = "Apache Proxy (assets)"
    "org.opencontainers.image.description" = "Apache reverse proxy for Mediawiki/Wikibase with static assets"
    "org.opencontainers.image.source"      = "https://github.com/MaRDI4NFDI/docker-wikibase/tree/main/apache_assets"
  }
}

# ==========================================
# 4. DEVELOPMENT ENVIRONMENT
# ==========================================
target "wikibase-dev" {
  context    = "./dev"
  dockerfile = "Dockerfile"
  tags       = ["ghcr.io/mardi4nfdi/wikibase-dev:${IMAGE_TAG}"]

  depends_on = ["wikibase"]

  contexts = {
    wikibase-local = "target:wikibase"
  }

  labels = {
    "org.opencontainers.image.title"       = "Wikibase Development"
    "org.opencontainers.image.description" = "Wikibase development environment with additional tools"
    "org.opencontainers.image.source"      = "https://github.com/MaRDI4NFDI/docker-wikibase/tree/main/dev"
  }
}
