# Renderer Interface Cleanup

## Why

`terraform-renderer-generic` became the shared rendering boundary for multiple
drivers, but its interface still had several flat inputs and compatibility gaps:

- linked setup settings were spread across multiple top-level variables
- README rendering settings were also split across multiple top-level variables
- generated module identity was not consistently represented as part of README
  rendering configuration
- Terraform Cloud consumers still saw unnecessary generated-file diffs caused by
  whitespace-only rendering differences

The shared renderer should present a cleaner grouped interface and preserve the
legacy Terraform Cloud generated file shape where no functional change exists.

## What

Refine the shared renderer interface and compatibility behavior by:

- grouping linked setup controls under `linked`
- grouping README rendering controls under `readme`
- moving generated output controls under `module_config.output`
- moving `generated_by_module` under `readme.generated_by_module`
- keeping registry-style module identifiers in driver-provided README context
- preserving Terraform Cloud generated file compatibility for:
  - legacy note text
  - `data.tfe_outputs.this[...]` references
  - linked workspace sanitization behavior
  - byte-for-byte `main.tf` whitespace layout where no semantic change exists

## Acceptance Criteria

- `terraform-renderer-generic` exposes grouped `linked` configuration instead of
  flat `linked_*` inputs
- `terraform-renderer-generic` exposes grouped `readme` configuration instead of
  flat `readme_*` inputs
- generated output settings are owned by `module_config.output`
- `readme.generated_by_module` is used to derive the default README module URL
- current renderer consumers migrate to the grouped interface without behavior
  regressions
- Terraform Cloud renderer consumers no longer receive unnecessary `main.tf`
  replacement diffs caused only by renderer whitespace differences
- grouped object fields in `variables.tf` include inline descriptive comments
