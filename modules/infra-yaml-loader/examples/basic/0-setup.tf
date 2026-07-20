module "infra_yaml_loader" {
  source = "../../"

  yamldir = "${path.module}/fixtures/basic"
}

module "infra_yaml_loader_empty_yaml" {
  source = "../../"

  yamldir = "${path.module}/fixtures/empty-yaml"
}
