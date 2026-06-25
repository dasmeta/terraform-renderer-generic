resource "terraform_data" "workspace_paths" {
  input = module.infra_yaml_fetched.yaml_paths
}

resource "terraform_data" "linked_workspaces" {
  input = module.infra_yaml_fetched.auto_detected_linked_workspaces
}
