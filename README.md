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

## Minimal Example

```hcl
module "this" {
  source = "dasmeta/terraform-renderer-generic"

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
- `provider_custom_var_blocks`: optional provider-specific custom blocks such as
  `aws.default_tags`
- `provider_default_tags`: optional provider-specific default tag settings.
  Currently supports AWS default tag injection with configurable tag values
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
| <a name="input_generated_by_module"></a> [generated\_by\_module](#input\_generated\_by\_module) | Module identifier written into generated README.md. | `string` | `"dasmeta/terraform-renderer-generic"` | no |
| <a name="input_linked_setup_result_mapping"></a> [linked\_setup\_result\_mapping](#input\_linked\_setup\_result\_mapping) | Optional explicit linked-setup result mapping used for interpolation replacement. When null, the module derives remote-state mappings from linked\_setups. | `any` | `null` | no |
| <a name="input_linked_setups"></a> [linked\_setups](#input\_linked\_setups) | Optional linked setup remote-state definitions used for generated output wiring in main.tf. | `any` | `{}` | no |
| <a name="input_main_tf_extra_content"></a> [main\_tf\_extra\_content](#input\_main\_tf\_extra\_content) | Optional extra Terraform content inserted before the generated module block in main.tf. | `string` | `null` | no |
| <a name="input_module_config"></a> [module\_config](#input\_module\_config) | Grouped Terraform module configuration rendered into generated files. | <pre>object({<br/>    source    = string<br/>    version   = string<br/>    variables = optional(any, {})<br/>    providers = optional(any, [])<br/>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Generated setup folder name and unique identifier. | `string` | n/a | yes |
| <a name="input_output"></a> [output](#input\_output) | Optional generated outputs.tf configuration. By default the module renders output "results" with value = module.this. | <pre>object({<br/>    enabled   = optional(bool, true)<br/>    sensitive = optional(bool, null)<br/>  })</pre> | `{}` | no |
| <a name="input_provider_custom_var_blocks"></a> [provider\_custom\_var\_blocks](#input\_provider\_custom\_var\_blocks) | Optional provider-specific custom blocks merged into provider rendering. Useful for blocks like aws.default\_tags. | `any` | `{}` | no |
| <a name="input_provider_default_tags"></a> [provider\_default\_tags](#input\_provider\_default\_tags) | Optional provider-specific default tag settings. Currently supports aws default\_tags injection. | `any` | `{}` | no |
| <a name="input_setup_path"></a> [setup\_path](#input\_setup\_path) | Optional relative output path for the generated setup. When unset, the normalized name is used. | `string` | `null` | no |
| <a name="input_target_dir"></a> [target\_dir](#input\_target\_dir) | Parent directory where the generated setup folder will be created. | `string` | `"./"` | no |
| <a name="input_terraform"></a> [terraform](#input\_terraform) | Grouped Terraform runtime configuration rendered into generated versions.tf. | <pre>object({<br/>    version = optional(string, "~> 1.3")<br/>    backend = optional(object({<br/>      name    = string<br/>      configs = optional(any, {})<br/>      }), {<br/>      name    = null<br/>      configs = null<br/>    })<br/>    cloud = optional(object({<br/>      organization = string<br/>    }), null)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_generated_dir"></a> [generated\_dir](#output\_generated\_dir) | Generated setup directory path. |
| <a name="output_generated_files"></a> [generated\_files](#output\_generated\_files) | Paths of generated files written to the target directory. |
| <a name="output_rendered_name"></a> [rendered\_name](#output\_rendered\_name) | Normalized generated setup name. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
