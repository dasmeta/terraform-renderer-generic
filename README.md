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
