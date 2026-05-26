# Bootstrap Generic Renderer Module

## Why

DasMeta needs a shared module that renders provider-agnostic Terraform setup
files from normalized driver input. Today that rendering logic is embedded
inside the Terraform Cloud driver and partially reimplemented in the Terramate
driver prototype.

To support the multi-driver architecture, the generic rendering boundary should
be extracted into its own shared module.

## What

Create `terraform-renderer-generic` as a shared root Terraform module that
renders:

- `main.tf`
- `versions.tf`
- `providers.tf` when provider definitions are supplied
- `outputs.tf`
- `README.md`

The module should accept one normalized setup definition at a time and write the
generated files into a target directory.

## Acceptance Criteria

- The new repo exists with a standard Terraform module layout.
- The root module renders the five generic Terraform files listed above.
- The implementation is derived from the reusable parts of
  `terraform-tfe-cloud/modules/workspace`.
- The module does not contain Terraform Cloud or Terramate-specific runtime
  resources.
- An executable example proves the renderer writes the expected files.
