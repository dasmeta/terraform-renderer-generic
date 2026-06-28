locals {
  root_shared_yaml = try(file("${var.yamldir}/_.yaml"), "")

  folders_shared_yaml = {
    for file in fileset(var.yamldir, "**/*/_.yaml") :
    replace(file, "/_.yaml$/", "") => try(file("${var.yamldir}/${file}"), "")
    if length(regexall("\\.terraform", file)) == 0
  }

  workspace_yaml_files = [
    for file in fileset(var.yamldir, "**/*.yaml") :
    file
    if local.is_workspace_yaml_file[file]
  ]

  is_workspace_yaml_file = {
    for file in fileset(var.yamldir, "**/*.yaml") :
    file => (
      length(regexall("\\.terraform", file)) == 0
      && length(regexall("(^|/)_\\.yaml$", file)) == 0
      && file != "metacloud.yaml"
      && length(regexall("(^|/)(_terragrunt|_terraform)/", file)) == 0
    )
  }

  yaml_files_raw = {
    for file in local.workspace_yaml_files :
    replace(file, "/.yaml$/", "") => try(
      yamldecode(
        join(
          "\n",
          concat(
            [local.root_shared_yaml],
            [for folder_name, shared_content in local.folders_shared_yaml : shared_content if strcontains(file, folder_name)],
            [file("${var.yamldir}/${file}")]
          )
        )
      ),
      {}
    )
  }

  is_local_module_source = {
    for key, item in local.yaml_files_raw :
    key => try(
      !startswith(tostring(item.source), "git::")
      && !startswith(tostring(item.source), "http://")
      && !startswith(tostring(item.source), "https://")
      && (
        startswith(tostring(item.source), ".")
        || startswith(tostring(item.source), "/")
        || startswith(tostring(item.source), "~")
      ),
      false
    )
  }

  yaml_files_resolved = {
    for key, item in local.yaml_files_raw :
    key => merge(item, {
      version = coalesce(
        try(item.version, null),
        local.is_local_module_source[key] ? "local" : null,
      )
    })
  }

  yaml_files = {
    for key, item in local.yaml_files_resolved :
    key => item
    if try(item.source, null) != null && try(item.version, null) != null
  }

  interpolation_detected_linked_workspaces = {
    for path, item in local.yaml_files :
    path => distinct([
      for match in flatten([
        for content in concat([try(item.variables, {})], try(item.providers, [])) :
        regexall("\\$${([^}]+)}", jsonencode(content))
      ]) :
      replace(match, "/(\\..+|\\[.+)/", "")
    ])
  }

  path_inferred_linked_workspaces = {
    for path in keys(local.yaml_files) :
    path => [
      "1-environments/${regex("^2-products/(.+)/[^/]+/setups/[^/]+$", path)}/${regex("^2-products/.+/([^/]+)/setups/[^/]+$", path)}/cluster"
    ]
    if can(regex("^2-products/.+/[^/]+/setups/[^/]+$", path))
    && contains(
      keys(local.yaml_files),
      "1-environments/${regex("^2-products/(.+)/[^/]+/setups/[^/]+$", path)}/${regex("^2-products/.+/([^/]+)/setups/[^/]+$", path)}/cluster"
    )
  }

  auto_detected_linked_workspaces = {
    for path in keys(local.yaml_files) :
    path => distinct(concat(
      try(local.interpolation_detected_linked_workspaces[path], []),
      try(local.path_inferred_linked_workspaces[path], []),
    ))
  }
}
