terraform {
  backend "http" {
  }
  required_providers {
    kypo = {
      source  = "vydrazde/kypo"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
    }
  }
}

provider "kypo" {
  endpoint = var.KYPO_ENDPOINT
}

provider "openstack" {
  auth_url = "https://identity.cloud.muni.cz/v3"
  region   = "brno1"
}

provider "gitlab" {
  base_url = "https://${var.CI_SERVER_HOST}/api/v4"
  token    = var.ACCESS_TOKEN
}

variable "KYPO_ENDPOINT" {}
variable "CI_PROJECT_ID" {}
variable "CI_PROJECT_URL" {}
variable "CI_COMMIT_SHORT_SHA" {}
variable "CI_SERVER_HOST" {}
variable "CI_PROJECT_PATH" {}
variable "NAME" {}
variable "TYPE" {}
variable "DISTRO" {}
variable "GUI_ACCESS" {}
variable "ACCESS_TOKEN" {
  sensitive = true
}

module "topology" {
  source               = "gitlab.ics.muni.cz/muni-kypo-images/image-testing-topology/kypo"
  kypo_endpoint        = var.KYPO_ENDPOINT
  project_url          = "${var.CI_SERVER_HOST}/${var.CI_PROJECT_PATH}"
  project_access_token = var.ACCESS_TOKEN
  project_id           = var.CI_PROJECT_ID
  rev                  = var.CI_COMMIT_SHORT_SHA
  image_name           = var.NAME
  os_type              = var.TYPE
  os_distro            = var.DISTRO
  gui_access           = var.GUI_ACCESS
}

output "pool_url" {
  value = module.topology.pool_url
}
