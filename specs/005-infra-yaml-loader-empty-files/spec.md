# Infra YAML Loader Empty Files

## Why

The shared `infra-yaml-loader` submodule normalizes every discovered workspace
YAML file before filtering incomplete entries. Empty YAML files, or YAML files
without both `source` and `version`, can therefore reach version normalization
with no usable version value.

The current normalization uses `coalesce()` for the explicit version and the
local-source fallback. When both values are null, Terraform fails before the
existing source/version filter can ignore the incomplete YAML entry.

This blocks YAML-driven consumers that tolerate placeholder or empty YAML files,
including the Terragrunt, Terramate, and Terraform Cloud driver modules.

## What

Update `modules/infra-yaml-loader` so that:

- an explicit YAML `version` is preserved when present
- a local module source with an omitted version still resolves to `local`
- a non-local source with an omitted version resolves to null and is filtered
- empty YAML files are ignored instead of aborting Terraform evaluation
- the existing loader behavior for valid workspace YAML remains unchanged

## Acceptance Criteria

- empty YAML files no longer trigger `coalesce()` failures during loader plan
- the loader example contains an executable regression case for an empty YAML
  file
- the loader example still validates existing workspace discovery, shared-config
  merge, workspace filtering, and linked-workspace detection
- temporary downstream validation confirms the fixed loader can be consumed by:
  - `terraform-terragrunt-cli`
  - `terraform-terramate-cli`
  - `terraform-tfe-cloud`

## Notes

- This is a compatibility bugfix for the loader normalization path; it does not
  change consumer registry pins. Consumer module version updates happen after a
  renderer release is published.
- `terraform-renderer-generic` has existing `specs/` packages but no `.specify/`
  command scaffold, so this package follows the established repository-local
  lightweight spec format.
