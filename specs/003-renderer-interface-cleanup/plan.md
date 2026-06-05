# Implementation Plan

## Scope

Apply a non-resource interface cleanup to `terraform-renderer-generic` and
align its active driver consumers with the new grouped interface.

## Steps

1. Refactor renderer input variables:
   - introduce grouped `linked`
   - introduce grouped `readme`
   - move output handling under `module_config.output`
2. Update renderer internals:
   - switch local normalization to grouped inputs
   - keep README rendering descriptive and generic
   - derive README module URL from `readme.generated_by_module`
3. Update active consumers:
   - Terraform Cloud workspace wrapper
   - Terramate driver
4. Preserve Terraform Cloud compatibility:
   - keep legacy `tfe_outputs` mapping shape
   - keep note wording
   - align `main.tf` whitespace byte-for-byte with old rendering
5. Update module docs and generated README docs output.
6. Validate Terraform Cloud workspace fixture.

## Validation

- `terraform -chdir=modules/workspace/tests/yaml-conf-and-workspace-link validate`
