# Implementation Plan

## Scope

Fix `modules/infra-yaml-loader` so incomplete or empty workspace YAML documents
can be filtered without failing during version normalization.

## Current State

- `local.yaml_files_raw` decodes each workspace YAML path or returns `{}` when
  decoding fails, including blank files.
- `local.yaml_files_resolved` currently calls `coalesce()` for every raw item
  before `local.yaml_files` filters entries missing `source` or `version`.
- `coalesce(null, null)` fails, so the filter cannot ignore empty or incomplete
  YAML entries.

## Steps

1. Add an empty-YAML fixture to the loader executable example.
2. Add a check block asserting empty YAML input produces no workspace paths.
3. Replace the `coalesce()` version normalization with a safe expression that:
   - returns `item.version` when present
   - returns `local` for local module sources when version is omitted
   - returns null when no version can be resolved
4. Run loader validation and plan checks.
5. Validate temporary downstream copies of Terragrunt, Terramate, and TFE Cloud
   consumers with their loader source pointed to this local module.

## Validation

- Red check: loader example failed before the fix with `Call to function
  "coalesce" failed: no non-null, non-empty-string arguments.`
- `terraform -chdir=modules/infra-yaml-loader validate`
- `terraform -chdir=modules/infra-yaml-loader/examples/basic validate`
- `terraform -chdir=modules/infra-yaml-loader/examples/basic plan -refresh=false`
- `terraform fmt -check -recursive .`
- `git diff --check`
- Temporary downstream validation under `/private/tmp/infra-yaml-loader-validation.*`:
  - Terragrunt examples: basic, linked-stacks, with-shared-configs
  - Terramate examples: basic, linked-stacks, backend-s3, with-shared-configs,
    backend-gitlab
  - TFE harnesses: empty YAML and shared-config YAML

## Validation Notes

- Several downstream example plans emit existing check-block warnings when copied
  state or generated output is stale and a check depends on data known only after
  apply. These warnings did not reproduce the loader failure.
- The TFE basic YAML harness exposed an existing downstream renderer issue where
  a workspace YAML without `variables` reaches renderer code as an empty tuple
  and fails `values()`. That is outside this loader version-normalization fix.

## Breaking Changes

None expected. Valid YAML workspaces still require both `source` and `version`
after normalization, and incomplete entries remain filtered out.

## Follow-Up

After the renderer release is published, update the downstream module pins in
`terraform-terragrunt-cli`, `terraform-terramate-cli`, and `terraform-tfe-cloud`
to consume the released loader version.
