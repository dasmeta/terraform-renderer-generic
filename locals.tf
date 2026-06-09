locals {
  name_specials_clean = replace(var.name, "/[^a-zA-Z0-9_-]+/", "_")
  setup_path_raw      = var.setup_path == null ? "" : trimspace(var.setup_path)
  setup_path          = local.setup_path_raw != "" ? trimsuffix(local.setup_path_raw, "/") : local.name_specials_clean
  effective_module_config = {
    source    = var.module_config.source
    version   = var.module_config.version
    variables = try(var.module_config.variables, {})
    providers = try(var.module_config.providers, [])
    output    = try(var.module_config.output, {})
  }
  effective_terraform = {
    version = try(var.terraform.version, "~> 1.3")
    backend = {
      name    = try(var.terraform.backend.name, null)
      configs = try(var.terraform.backend.configs, null)
    }
    cloud = {
      organization = try(var.terraform.cloud.organization, null)
    }
  }
  effective_linked = {
    setups                  = try(var.linked.setups, {})
    result_mapping          = try(var.linked.result_mapping, null)
    result_mapping_template = try(var.linked.result_mapping_template, null)
    data_content_template   = try(var.linked.data_content_template, null)
    query = {
      organization = try(var.linked.query.organization, null)
    }
  }
  effective_readme = {
    generated_by_module  = try(var.readme.generated_by_module, "dasmeta/generic/renderer")
    intro                = try(var.readme.intro, null)
    module_url           = try(var.readme.module_url, null)
    setup_label          = try(var.readme.setup_label, null)
    module_source_label  = try(var.readme.module_source_label, null)
    module_version_label = try(var.readme.module_version_label, null)
  }

  module_nested_provider = {
    for provider in local.effective_module_config.providers :
    "${provider.name}${try(provider.alias, "") != "" ? ".${provider.alias}" : ""}" =>
    "${provider.name}${try(provider.alias, "") != "" ? ".${provider.alias}" : ""}"
    if try(provider.module_nested_provider, false)
  }

  module_providers_grouped = { for provider in local.effective_module_config.providers : provider.name => provider... }
  has_module_providers     = length(local.effective_module_config.providers) > 0
  auto_detected_linked_setups = [
    for item in flatten([
      for content in concat(
        [for var_value in values(local.effective_module_config.variables) : var_value],
        local.effective_module_config.providers
      ) : regexall("\\$${([^}]+)}", jsonencode(content))
    ]) : replace(item, "/([.\\[].+)/", "")
  ]
  explicit_linked_setup_names  = keys(local.effective_linked.setups)
  effective_linked_setup_names = distinct(concat(local.explicit_linked_setup_names, local.auto_detected_linked_setups))
  has_linked_setups            = length(local.effective_linked_setup_names) > 0
  linked_setups_encoded = {
    for setup_name in local.effective_linked_setup_names :
    setup_name => {
      backend = try(local.effective_linked.setups[setup_name].backend, null)
      config  = try(local.effective_linked.setups[setup_name].config, null)
    }
  }
  render_default_linked_setup_data = local.has_linked_setups && local.effective_linked.result_mapping == null && local.effective_linked.result_mapping_template == null && length([
    for setup_name, setup in local.linked_setups_encoded :
    setup_name
    if setup.backend != null
  ]) == length(local.effective_linked_setup_names)
  linked_setup_mapping = local.effective_linked.result_mapping != null ? local.effective_linked.result_mapping : (
    local.effective_linked.result_mapping_template != null ? {
      for setup_name in local.effective_linked_setup_names :
      setup_name => format(local.effective_linked.result_mapping_template, setup_name)
      } : {
      for setup_name in local.effective_linked_setup_names :
      setup_name => "data.terraform_remote_state.linked[\\\"${setup_name}\\\"].outputs.results"
    }
  )
  effective_linked_setup_mapping = local.linked_setup_mapping
  linked_setup_data_content = local.has_linked_setups && local.effective_linked.data_content_template != null ? replace(
    replace(
      replace(
        local.effective_linked.data_content_template,
        "__NOTE__",
        var.note
      ),
      "__LINKED_SETUPS_JSON__",
      jsonencode(local.effective_linked_setup_names)
    ),
    "__LINKED_SETUP_QUERY_ORGANIZATION__",
    local.effective_linked.query.organization == null ? "" : local.effective_linked.query.organization
  ) : null
  combined_main_tf_extra_content = join("\n\n", compact([
    local.linked_setup_data_content,
    var.main_tf_extra_content
  ]))
  provider_custom_var_blocks = {
    for provider_name, provider_config in var.provider_configs :
    provider_name => try(provider_config.custom_var_blocks, {})
    if try(provider_config.custom_var_blocks, null) != null
  }
  aws_default_tags_config = try(var.provider_configs.aws.default_tags, null)
  aws_generated_default_tags = local.aws_default_tags_config != null && try(local.aws_default_tags_config.enabled, false) ? {
    default_tags = {
      tags = merge(
        {
          ManagedBy              = try(local.aws_default_tags_config.managed_by, "terraform")
          TerraformModuleSource  = local.effective_module_config.source
          TerraformModuleVersion = local.effective_module_config.version
        },
        try(local.aws_default_tags_config.applied_from, null) != null ? {
          AppliedFrom = local.aws_default_tags_config.applied_from
        } : {},
        try(local.aws_default_tags_config.workspace_tag_name, null) != null ? {
          (local.aws_default_tags_config.workspace_tag_name) = coalesce(try(local.aws_default_tags_config.workspace_tag_value, null), local.name_specials_clean)
        } : {},
        try(local.aws_default_tags_config.extra_tags, {})
      )
    }
  } : {}
  effective_provider_custom_var_blocks = merge(
    local.provider_custom_var_blocks,
    local.aws_generated_default_tags != {} ? {
      aws = provider::deepmerge::mergo(try(local.provider_custom_var_blocks.aws, {}), local.aws_generated_default_tags)
    } : {}
  )
  rendered_provider_custom_var_blocks = {
    for provider_name, provider_blocks in local.effective_provider_custom_var_blocks :
    provider_name => {
      for key, value in provider_blocks :
      key => (
        local.has_linked_setups ?
        jsondecode(format(
          replace(replace(jsonencode(value), "%", "%%"), "/(${join("|", keys(local.effective_linked_setup_mapping))})/", "%s"),
          [for linked_key in flatten(regexall("(${join("|", keys(local.effective_linked_setup_mapping))})", replace(jsonencode(value), "%", "%%"))) : try(local.effective_linked_setup_mapping[linked_key], "")]...
        )) :
        value
      )
    }
  }
  provider_custom_block_keys_by_provider = {
    for provider_name, provider_blocks in local.rendered_provider_custom_var_blocks :
    provider_name => keys(provider_blocks)
  }
  provider_custom_vars_default_merged = {
    for provider in local.effective_module_config.providers :
    "${provider.name}${try(provider.alias, null) == null ? "" : "-${provider.alias}"}" => provider::deepmerge::mergo(
      try(provider.variables, {}),
      try(local.rendered_provider_custom_var_blocks[provider.name], {})
    )
  }
  module_vars_rendered = {
    for key, value in local.effective_module_config.variables :
    key => (
      local.has_linked_setups ?
      jsondecode(format(
        replace(replace(jsonencode(value), "%", "%%"), "/(${join("|", keys(local.effective_linked_setup_mapping))})/", "%s"),
        [for linked_key in flatten(regexall("(${join("|", keys(local.effective_linked_setup_mapping))})", replace(jsonencode(value), "%", "%%"))) : try(local.effective_linked_setup_mapping[linked_key], "")]...
      )) :
      value
    )
  }
  providers_rendered = [for provider in local.effective_module_config.providers : merge(provider, {
    alias = try(provider.alias, null)
    variables = {
      for key, value in try(provider.variables, {}) :
      key => (
        local.has_linked_setups ?
        jsondecode(format(
          replace(replace(jsonencode(value), "%", "%%"), "/(${join("|", keys(local.effective_linked_setup_mapping))})/", "%s"),
          [for linked_key in flatten(regexall("(${join("|", keys(local.effective_linked_setup_mapping))})", replace(jsonencode(value), "%", "%%"))) : try(local.effective_linked_setup_mapping[linked_key], "")]...
        )) :
        value
      )
      if !try(contains(local.provider_custom_block_keys_by_provider[provider.name], key), false)
    }
    blocks = {
      for key, value in try(provider.blocks, {}) :
      key => (
        local.has_linked_setups ?
        jsondecode(format(
          replace(replace(jsonencode(value), "%", "%%"), "/(${join("|", keys(local.effective_linked_setup_mapping))})/", "%s"),
          [for linked_key in flatten(regexall("(${join("|", keys(local.effective_linked_setup_mapping))})", replace(jsonencode(value), "%", "%%"))) : try(local.effective_linked_setup_mapping[linked_key], "")]...
        )) :
        value
      )
      if !try(contains(local.provider_custom_block_keys_by_provider[provider.name], key), false)
    }
    custom_var_blocks = {
      for key, value in merge(
        {
          for key, value in try(provider.custom_var_blocks, {}) :
          key => (
            local.has_linked_setups ?
            jsondecode(format(
              replace(replace(jsonencode(value), "%", "%%"), "/(${join("|", keys(local.effective_linked_setup_mapping))})/", "%s"),
              [for linked_key in flatten(regexall("(${join("|", keys(local.effective_linked_setup_mapping))})", replace(jsonencode(value), "%", "%%"))) : try(local.effective_linked_setup_mapping[linked_key], "")]...
            )) :
            value
          )
          if !try(contains(local.provider_custom_block_keys_by_provider[provider.name], key), false)
        },
        {
          for key, value in try(local.provider_custom_vars_default_merged["${provider.name}${try(provider.alias, null) == null ? "" : "-${provider.alias}"}"], {}) :
          key => value
          if try(contains(local.provider_custom_block_keys_by_provider[provider.name], key), false)
        }
      ) :
      key => (
        local.has_linked_setups ?
        jsondecode(format(
          replace(replace(jsonencode(value), "%", "%%"), "/(${join("|", keys(local.effective_linked_setup_mapping))})/", "%s"),
          [for linked_key in flatten(regexall("(${join("|", keys(local.effective_linked_setup_mapping))})", replace(jsonencode(value), "%", "%%"))) : try(local.effective_linked_setup_mapping[linked_key], "")]...
        )) :
        value
      )
    }
  })]

  main_content = templatefile(
    "${path.module}/templates/main.tf.tftpl",
    {
      note                   = var.note
      source                 = local.effective_module_config.source
      version                = local.effective_module_config.version
      module_nested_provider = local.module_nested_provider == {} ? null : local.module_nested_provider
      linked_setups          = local.render_default_linked_setup_data ? jsonencode(local.linked_setups_encoded) : null
      extra_content          = local.combined_main_tf_extra_content != "" ? local.combined_main_tf_extra_content : null
      variables              = local.module_vars_rendered
    }
  )

  versions_content = templatefile(
    "${path.module}/templates/versions.tf.tftpl",
    {
      note              = var.note
      name              = local.name_specials_clean
      terraform_version = local.effective_terraform.version
      providers = [for group in local.module_providers_grouped : {
        name                  = group[0].name
        version               = group[0].version
        source                = coalesce(try(group[0].source, null), "hashicorp/${group[0].name}")
        configuration_aliases = replace(jsonencode([for item in group : "${group[0].name}.${try(item.alias, null)}" if try(item.alias, null) != null]), "\"", "")
      }]
      terraform_backend = {
        name    = local.effective_terraform.backend.name
        configs = { for key, value in local.effective_terraform.backend.configs : key => jsonencode(value) }
      }
      terraform_cloud = {
        organization = local.effective_terraform.cloud.organization
      }
    }
  )

  providers_content = templatefile(
    "${path.module}/templates/providers.tf.tftpl",
    {
      note      = var.note
      providers = local.providers_rendered
    }
  )

  outputs_content = templatefile(
    "${path.module}/templates/outputs.tf.tftpl",
    {
      note      = var.note
      sensitive = try(local.effective_module_config.output.sensitive, null)
    }
  )

  readme_module_url = coalesce(local.effective_readme.module_url, "https://github.com/${local.effective_readme.generated_by_module}")

  readme_content = templatefile(
    "${path.module}/templates/README.md.tftpl",
    {
      intro                = local.effective_readme.intro
      module_url           = local.readme_module_url
      setup_label          = local.effective_readme.setup_label
      setup_name           = local.name_specials_clean
      module_source_label  = local.effective_readme.module_source_label
      module_source        = local.effective_module_config.source
      module_version_label = local.effective_readme.module_version_label
      module_version       = local.effective_module_config.version
    }
  )

  files_to_generate = [
    {
      name    = "main.tf"
      content = local.main_content
    },
    {
      name    = "versions.tf"
      content = local.versions_content
    },
    {
      name    = "outputs.tf"
      content = local.outputs_content
    },
    {
      name    = "README.md"
      content = local.readme_content
    },
  ]

  files_to_generate_with_optional_providers = concat(
    [
      for file in local.files_to_generate :
      file
      if file.name != "outputs.tf" || try(local.effective_module_config.output.enabled, true)
    ],
    local.has_module_providers ? [
      {
        name    = "providers.tf"
        content = local.providers_content
      }
    ] : []
  )
}
