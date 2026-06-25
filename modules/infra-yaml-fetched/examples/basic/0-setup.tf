module "infra_yaml_fetched" {
  source = "../../"

  yamldir = "${path.module}/fixtures/basic"
}
