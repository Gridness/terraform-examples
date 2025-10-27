resource "random_password" "nibop_pass" {
  length  = 12
  special = true
}

resource "harbor_user" "nibop" {
  username  = "nibop"
  password  = random_password.nibop_pass.result
  full_name = "omitted"
  email     = "omitted"
}

resource "harbor_project" "images" {
  name                        = "images"
  public                      = true
  vulnerability_scanning      = true
  enable_content_trust        = true
  enable_content_trust_cosign = true
  auto_sbom_generation        = true
}

resource "harbor_project" "charts" {
  name                        = "charts"
  public                      = true
  vulnerability_scanning      = true
  enable_content_trust        = true
  enable_content_trust_cosign = true
  auto_sbom_generation        = true
}

resource "harbor_project" "mirror" {
  name                        = "mirror"
  public                      = true
  vulnerability_scanning      = false
  enable_content_trust        = true
  enable_content_trust_cosign = false
  auto_sbom_generation        = false
}

resource "harbor_retention_policy" "mirror" {
  scope    = harbor_project.mirror.id
  schedule = "Daily"
  rule {
    most_recently_pushed = 5
    repo_matching        = "**"
  }
}

resource "harbor_project" "docker_hub_mirror" {
  name        = "dockerhub"
  public      = true
  registry_id = harbor_registry.docker.registry_id
}

resource "harbor_retention_policy" "docker_hub_mirror" {
  scope    = harbor_project.docker_hub_mirror.id
  schedule = "Daily"
  rule {
    most_recently_pulled = 5
    repo_matching        = "**"
  }
}

resource "harbor_project" "github_mirror" {
  name        = "ghcr"
  public      = true
  registry_id = harbor_registry.github.registry_id
}

resource "harbor_retention_policy" "github_mirror" {
  scope    = harbor_project.github_mirror.id
  schedule = "Daily"
  rule {
    most_recently_pulled = 5
    repo_matching        = "**"
  }
}

resource "harbor_registry" "docker" {
  provider_name = "docker-hub"
  name          = "Docker Hub"
  endpoint_url  = "https://hub.docker.com"
}

resource "harbor_registry" "github" {
  provider_name = "github"
  name          = "GHCR"
  endpoint_url  = "https://ghcr.io"
}

resource "harbor_robot_account" "mirror" {
  name        = "mirror"
  description = "Bot account to manage mirrors of artifacts"
  disable     = false
  duration    = -1
  level       = "system"
  permissions {
    access {
      action   = "pull"
      resource = "repository"
      effect   = "allow"
    }
    access {
      action   = "read"
      resource = "repository"
      effect   = "allow"
    }
    access {
      action   = "push"
      resource = "repository"
      effect   = "allow"
    }
    access {
      action   = "update"
      resource = "repository"
      effect   = "allow"
    }
    kind      = "project"
    namespace = "mirror"
  }
}

resource "random_password" "argocd_mirror_pass" {
  length  = 12
  special = false
}

resource "harbor_robot_account" "argocd_mirror" {
  name        = "argocd-mirror"
  description = "Bot account to access mirrors of artifacts for argocd"
  disable     = false
  duration    = -1
  level       = "system"
  secret      = random_password.argocd_mirror_pass.result
  permissions {
    access {
      action   = "pull"
      resource = "repository"
      effect   = "allow"
    }
    access {
      action   = "read"
      resource = "repository"
      effect   = "allow"
    }
    kind      = "project"
    namespace = "mirror"
  }
}

resource "random_password" "argocd_pass" {
  length  = 12
  special = false
}

resource "harbor_robot_account" "argocd" {
  name        = "argocd"
  description = "Bot account to access internal artifacts for argocd"
  disable     = false
  duration    = -1
  level       = "system"
  secret      = random_password.argocd_pass.result
  permissions {
    access {
      action   = "pull"
      resource = "repository"
      effect   = "allow"
    }
    access {
      action   = "read"
      resource = "repository"
      effect   = "allow"
    }
    kind      = "project"
    namespace = "images"
  }
  permissions {
    access {
      action   = "pull"
      resource = "repository"
      effect   = "allow"
    }
    access {
      action   = "read"
      resource = "repository"
      effect   = "allow"
    }
    kind      = "project"
    namespace = "charts"
  }
}

resource "harbor_garbage_collection" "main" {
  schedule        = "Daily"
  delete_untagged = true
  workers         = 1
}

resource "harbor_immutable_tag_rule" "mirror" {
  disabled      = true
  project_id    = harbor_project.mirror.id
  repo_matching = "**"
  tag_matching  = "v*.*"
  tag_excluding = "latest"
}

resource "harbor_immutable_tag_rule" "charts" {
  disabled      = false
  project_id    = harbor_project.charts.id
  repo_matching = "**"
  tag_matching  = "v*.*"
  tag_excluding = "latest"
}

resource "harbor_immutable_tag_rule" "images" {
  disabled      = false
  project_id    = harbor_project.images.id
  repo_matching = "**"
  tag_matching  = "v*.*"
  tag_excluding = "latest"
}

resource "harbor_config_system" "main" {
  project_creation_restriction = "adminonly"
  robot_name_prefix            = "harbor@"
  storage_per_project          = 100
  banner_message {
    closable  = var.banner_closable
    message   = var.banner_message
    type      = var.banner_type
    from_date = var.banner_from_date
    to_date   = var.banner_to_date
  }
}

resource "harbor_label" "production" {
  name        = "production"
  color       = "#800080"
  description = "production artifact"
}
