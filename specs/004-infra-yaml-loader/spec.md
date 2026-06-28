# Infra YAML Loader Submodule

## Why

Terragrunt, Terramate, and Terraform Cloud driver modules duplicated the same
YAML discovery, shared-config merge, workspace filtering, and linked-workspace
detection logic in each `locals.tf`.

That duplication made behavior drift likely and forced every driver fix to be
repeated three times.

## What

Add a reusable submodule at `modules/infra-yaml-loader` inside
`terraform-renderer-generic` that:

- merges root `_.yaml` and folder `**/_.yaml` shared configs into workspace YAML
- filters out shared-config files, `metacloud.yaml`, generated `_terragrunt/` /
  `_terraform/` paths, and `.terraform` directories
- keeps only workspaces with both `source` and `version`
- auto-detects linked workspace paths from `$${...}` interpolation in variables
  and providers
- exposes `yaml_files`, `yaml_files_raw`, `yaml_paths`, and
  `auto_detected_linked_workspaces`

Driver modules consume it from the registry:

```hcl
module "infra_yaml_loader" {
  source  = "dasmeta/generic/renderer//modules/infra-yaml-loader"
  version = "x.y.z"

  yamldir = var.yamldir
}
```

## Acceptance Criteria

- `modules/infra-yaml-loader` exists with variables, locals, outputs, versions,
  README, and an executable example with check blocks
- root renderer README documents the submodule
- example validates shared-config merge, workspace filtering, and linked-workspace
  auto-detection
- driver modules can depend on the published registry submodule after release
