# terraform-renderer-generic

`terraform-renderer-generic` is the intended published identity of this shared
Terraform renderer module.

This module renders a generic
Terraform setup into a target directory.

It is intended to hold the provider-agnostic file generation boundary that can
be reused by multiple drivers such as Terramate and Terraform Cloud based
workflows.

## What It Generates

- `main.tf`
- `versions.tf`
- `providers.tf` when provider definitions are supplied
- `outputs.tf`
- `README.md`

## What It Does Not Generate

- driver-specific files such as `stack.tm.hcl`
- Terraform Cloud resources or settings
- Terramate-specific dependency metadata

## Submodules

### `modules/infra-yaml-fetched`

Fetches and merges MetaCloud infrastructure YAML workspace definitions for Terragrunt,
Terramate, and Terraform Cloud driver modules:

- merges root and folder `_.yaml` shared configs
- filters `metacloud.yaml`, shared configs, and generated `_terragrunt/` / `_terraform/` paths
- keeps only workspaces with `source` and `version`
- auto-detects linked workspace paths from `$${...}` interpolation

```hcl
module "infra_yaml_fetched" {
  source  = "dasmeta/generic/renderer//modules/infra-yaml-fetched"
  version = "1.1.0"

  yamldir = var.yamldir
}
```

## Minimal Example

```hcl
module "this" {
  source = "dasmeta/generic/renderer"

  name       = "example-stack"
  target_dir = "./generated"
  module_config = {
    source   = "dasmeta/empty/null"
    version  = "1.2.2"
    variables = {}
    providers = []
  }
}
```

## Inputs

- `name`: generated setup folder name
- `module_config`: grouped Terraform module source, version, variables, and
  providers for generated files
- `target_dir`: parent directory where the generated setup folder is created
- `terraform`: grouped Terraform runtime configuration, including version,
  backend, and optional Terraform Cloud settings
- `linked_setups`: optional linked stack remote-state definitions rendered into
  generated `main.tf`
- `provider_configs`: optional grouped provider-specific configuration,
  including `custom_var_blocks` and provider `default_tags`
- `linked_setup_result_mapping`: optional explicit linked-output mapping used
  for interpolation replacement
- `main_tf_extra_content`: optional extra Terraform content inserted before the
  generated module block
- `output`: optional generated output configuration. Defaults to rendering
  `output "results" { value = module.this }`, supports `sensitive = true`,
  and can be disabled with `enabled = false`
- `generated_by_module`: module identifier written into generated README content

## Outputs

- `generated_files`: rendered file paths
- `generated_dir`: rendered setup directory path
- `rendered_name`: normalized generated setup name

## Local Validation

```bash
terraform -chdir=examples/basic init -input=false
terraform -chdir=examples/basic apply -auto-approve
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_deepmerge"></a> [deepmerge](#requirement\_deepmerge) | ~> 1.2 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | ~> 2.5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [local_file.this](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_linked"></a> [linked](#input\_linked) | Grouped linked-setup configuration used for interpolation replacement and generated linked setup data content. | <pre>object({<br/>    setups                  = optional(any, {})      # Explicit linked setup definitions keyed by referenced setup name.<br/>    result_mapping          = optional(any, null)    # Optional explicit interpolation target mapping for linked setup results.<br/>    result_mapping_template = optional(string, null) # Optional format string used to derive linked setup result mappings.<br/>    data_content_template   = optional(string, null) # Optional extra Terraform content template used for linked setup data blocks.<br/>    query = optional(object({<br/>      organization = optional(string, null) # Optional organization context used by driver-specific linked setup queries.<br/>    }), {})                                 # Optional query context for wrapper-provided linked setup content templates.<br/>  })</pre> | `{}` | no |
| <a name="input_main_tf_extra_content"></a> [main\_tf\_extra\_content](#input\_main\_tf\_extra\_content) | Optional extra Terraform content inserted before the generated module block in main.tf. | `string` | `null` | no |
| <a name="input_module_config"></a> [module\_config](#input\_module\_config) | Grouped Terraform module configuration rendered into generated files. | <pre>object({<br/>    source    = string            # Terraform module source to render into the generated setup.<br/>    version   = string            # Terraform module version constraint or exact version to render.<br/>    variables = optional(any, {}) # Input variables passed to the generated module block.<br/>    providers = optional(any, []) # Provider definitions rendered into generated provider and version files.<br/>    output = optional(object({<br/>      enabled   = optional(bool, true) # Whether to render outputs.tf for the generated setup.<br/>      sensitive = optional(bool, null) # Whether the generated results output should be marked sensitive.<br/>    }), {})                            # Output rendering options that belong to the generated module setup.<br/>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Generated setup folder name and unique identifier. | `string` | n/a | yes |
| <a name="input_note"></a> [note](#input\_note) | Note/comment text used in generated files. | `string` | `"This file and its content are generated based on config, pleas check README.md for more details"` | no |
| <a name="input_provider_configs"></a> [provider\_configs](#input\_provider\_configs) | Optional grouped provider-specific configuration, including custom variable blocks and default tag settings. | `any` | `{}` | no |
| <a name="input_readme"></a> [readme](#input\_readme) | Grouped README rendering configuration for generated setup documentation. | <pre>object({<br/>    generated_by_module  = optional(string, "dasmeta/generic/renderer")                                                                                                                                                                                                                                                                                                                                                                                                                                                        # Module identifier used to derive the generated README module URL.<br/>    intro                = optional(string, "This folder content has been generated by using a special Terraform code generator module. Direct or manual changes in this folder should be avoided unless there is a special need, such as debugging or applying a hotfix. Please follow the flow, format, and instructions for managing this content through configuration files, most likely YAML files in the repository root, and the corresponding CI/CD action or Terraform generator code located next to those files.") # Introductory README paragraph rendered above setup metadata.<br/>    module_url           = optional(string, null)                                                                                                                                                                                                                                                                                                                                                                                                                                                                              # Module URL shown in the generated README.<br/>    setup_label          = optional(string, "generated setup name")                                                                                                                                                                                                                                                                                                                                                                                                                                                            # Label used for the generated setup identity line.<br/>    module_source_label  = optional(string, "tf module source")                                                                                                                                                                                                                                                                                                                                                                                                                                                                # Label used for the Terraform module source line.<br/>    module_version_label = optional(string, "tf module version")                                                                                                                                                                                                                                                                                                                                                                                                                                                               # Label used for the Terraform module version line.<br/>  })</pre> | `{}` | no |
| <a name="input_setup_path"></a> [setup\_path](#input\_setup\_path) | Optional relative output path for the generated setup. When unset, the normalized name is used. | `string` | `null` | no |
| <a name="input_target_dir"></a> [target\_dir](#input\_target\_dir) | Parent directory where the generated setup folder will be created. | `string` | `"./"` | no |
| <a name="input_terraform"></a> [terraform](#input\_terraform) | Grouped Terraform runtime configuration rendered into generated versions.tf. | <pre>object({<br/>    version = optional(string, "~> 1.3") # Terraform version constraint rendered into versions.tf.<br/>    backend = optional(object({<br/>      name    = string            # Terraform backend type rendered into versions.tf.<br/>      configs = optional(any, {}) # Backend configuration arguments rendered for the backend block.<br/>      }), {<br/>      name    = null # No backend block is rendered when backend.name is null.<br/>      configs = null # No backend config entries are rendered when backend.configs is null.<br/>    })               # Backend rendering settings for the generated setup.<br/>    cloud = optional(object({<br/>      organization = string # Terraform Cloud organization name rendered into the cloud block.<br/>    }), null)               # Optional Terraform Cloud runtime configuration for the generated setup.<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_effective_linked_setups"></a> [effective\_linked\_setups](#output\_effective\_linked\_setups) | Effective linked setup names after merging explicit and auto-detected references. |
| <a name="output_generated_dir"></a> [generated\_dir](#output\_generated\_dir) | Generated setup directory path. |
| <a name="output_generated_files"></a> [generated\_files](#output\_generated\_files) | Paths of generated files written to the target directory. |
| <a name="output_rendered_name"></a> [rendered\_name](#output\_rendered\_name) | Normalized generated setup name. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
