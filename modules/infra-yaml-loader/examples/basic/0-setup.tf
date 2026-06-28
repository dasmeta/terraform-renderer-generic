module "infra_yaml_loader" {
  source = "../../"

  yamldir = "${path.module}/fixtures/basic"
}
