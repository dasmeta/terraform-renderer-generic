# Shared Driver Renderer Convergence

## Why

`terraform-renderer-generic` was bootstrapped as a shared generic Terraform
file renderer, but the most complex reusable logic still lives inside
`terraform-tfe-cloud/modules/workspace`.

That leaves the Terraform Cloud driver and Terramate driver with overlapping
logic and prevents the intended multi-driver architecture from being real. The
shared module should own the generic rendering complexity so each driver can
become a smaller wrapper around it.

## What

Extend `terraform-renderer-generic` so it becomes the canonical shared renderer
for generic Terraform setup generation across drivers.

The module should absorb:

- grouped module configuration through `module_config`
- generic module source/version/variable rendering
- generic provider rendering
- generic backend rendering
- generic output rendering
- generic README rendering
- generic linked-setup interpolation replacement

The module should remain free of driver-specific runtime resources such as:

- `tfe_*` resources
- Terramate stack files
- Terraform Cloud workspace/project orchestration

## Design

### Interface

Replace the current `module_*` top-level input sprawl with a grouped object:

- `module_config = { source, version, variables, providers }`

Keep these top-level inputs separate for now:

- `name`
- `setup_path`
- `target_dir`
- `terraform_version`
- `terraform_backend`
- `linked_setups`
- `output`
- `generated_by_module`

### Shared Logic Ownership

The shared renderer should own all generic file-content assembly and the generic
interpolation replacement model. Driver-specific wrappers should only provide:

- the normalized module input
- the linked-setup mapping source
- any driver-specific extra files or runtime resources

### Compatibility Scope

This is a coordinated breaking change for current local consumers:

- `terramate-poc`
- `terraform-tfe-cloud/modules/workspace`

Both consumers must migrate in the same implementation sequence.

## Acceptance Criteria

- `terraform-renderer-generic` accepts grouped `module_config`
- the module still renders generic `main.tf`, `versions.tf`, `providers.tf`
  when needed, `outputs.tf`, and `README.md`
- generic linked-setup interpolation replacement is owned by the shared module
- no Terraform Cloud or Terramate runtime resources are added to the shared
  module
- `terramate-poc` and `terraform-tfe-cloud/modules/workspace` can both consume
  the new interface through local relative source paths
