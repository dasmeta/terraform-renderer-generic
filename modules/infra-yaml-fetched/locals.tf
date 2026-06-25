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

  yaml_files = {
    for key, item in local.yaml_files_raw :
    key => item
    if try(item.source, null) != null && try(item.version, null) != null
  }

  auto_detected_linked_workspaces = {
    for path, item in local.yaml_files :
    path => distinct([
      for match in flatten([
        for content in concat([try(item.variables, {})], try(item.providers, [])) :
        regexall("\\$${([^}]+)}", jsonencode(content))
      ]) :
      replace(match, "/(\\..+|\\[.+)/", "")
    ])
  }
}
