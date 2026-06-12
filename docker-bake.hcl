variable "B_TAGS" {
  default = "{\"tag-names\":[\"latest\"]}"
}

variable "TAGS" {
  default = jsondecode(B_TAGS).tag-names
}
group "default" {
  targets = ["image-stack"]
}
target "image-stack" {
  matrix = {
    item = [
      { name = "wikibase",      desc = "Mediawiki/Wikibase image for the MaRDI portal", dir = ".",               dep = [],                     ctx = {} },
      { name = "apache",        desc = "Apache reverse proxy for the MaRDI portal",     dir = "./apache",        dep = [],                     ctx = {} },
      { name = "apache-assets", desc = "Reverse proxy with static assets for MaRDI",    dir = "./apache_assets", dep = ["wikibase", "apache"], ctx = { "wikibase-local" = "target:image-stack-wikibase", "apache-local" = "target:image-stack-apache" } },
      { name = "wikibase-dev",  desc = "Mediawiki dev image for the MaRDI portal",      dir = "./dev",           dep = ["wikibase"],           ctx = { "wikibase-local" = "target:image-stack-wikibase" } }
    ]
  }

  name        = "image-stack-${item.name}"
  context     = item.dir
  dockerfile  = "Dockerfile"

  depends_on  = [for d in item.dep : "image-stack-${d}"]
  contexts    = item.ctx

  tags = [for t in TAGS : "ghcr.io/mardi4nfdi/${item.name}:${t}"]

  labels = {
    "org.opencontainers.image.title"       = "MaRDI ${item.name} Container"
    "org.opencontainers.image.description" = item.desc
    "org.opencontainers.image.source"      = "https://github.com/MaRDI4NFDI/docker-wikibase/tree/main/${item.dir}"
  }
}
