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

check "detects_linked_workspaces_in_provider_config" {
  assert {
    condition = try(module.infra_yaml_loader_tiered.auto_detected_linked_workspaces["2-products/demo/dev/app"], []) == tolist([
      "1-environments/dev/eks"
    ])
    error_message = "An interpolation reference inside a provider config should link the referenced workspace."
  }
}

check "does_not_infer_links_from_directory_layout" {
  assert {
    condition     = length(try(module.infra_yaml_loader_tiered.auto_detected_linked_workspaces["2-products/demo/prod/app"], ["missing"])) == 0
    error_message = "A workspace with no explicit or referenced dependency must not be linked by its path alone."
  }

  assert {
    condition     = length(try(module.infra_yaml_loader_tiered.auto_detected_linked_workspaces["1-environments/dev/eks"], ["missing"])) == 0
    error_message = "An environment workspace must not gain links from tiered path naming."
  }
}

check "ignores_empty_yaml_files" {
  assert {
    condition     = length(module.infra_yaml_loader_empty_yaml.yaml_paths) == 0
    error_message = "Empty YAML files without source and version should be ignored."
  }
}
