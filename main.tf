provider "aws" {
  alias  = "primary"
  region = var.regions[0]
}

provider "aws" {
  alias  = "secondary"
  region = var.regions[1]
}

module "vpc" {
  source = "./vpc.tf"
}

module "web" {
  source = "./web.tf"
  depends_on = [module.vpc]
}

module "app" {
  source = "./app.tf"
  depends_on = [module.vpc]
}

module "db" {
  source = "./db.tf"
  depends_on = [module.vpc]
}
