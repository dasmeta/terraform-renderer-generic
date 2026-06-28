check "excludes_metacloud_and_shared_configs" {
  assert {
    condition     = !contains(module.infra_yaml_loader.yaml_paths, "metacloud")
    error_message = "metacloud.yaml must not be treated as a workspace."
  }

  assert {
    condition     = length([for path in module.infra_yaml_loader.yaml_paths : path if endswith(path, "/_") || path == "_"]) == 0
    error_message = "Shared _ yaml files must not be treated as workspaces."
  }
}

check "includes_workspaces_with_source_and_version" {
  assert {
    condition     = contains(module.infra_yaml_loader.yaml_paths, "group-0/module-a")
    error_message = "Expected group-0/module-a workspace to be discovered."
  }

  assert {
    condition     = contains(module.infra_yaml_loader.yaml_paths, "group-1/module-c")
    error_message = "Expected group-1/module-c workspace to be discovered."
  }
}

check "merges_shared_yaml" {
  assert {
    condition     = try(module.infra_yaml_loader.yaml_files["group-0/module-a"].variables.shared_tag, null) == "root-and-folder"
    error_message = "Root and folder shared YAML should merge into workspace variables."
  }
}

check "auto_detects_linked_workspaces" {
  assert {
    condition     = contains(try(module.infra_yaml_loader.auto_detected_linked_workspaces["group-1/module-c"], []), "group-0/module-a")
    error_message = "Linked workspace references should be auto-detected from interpolation."
  }
}
