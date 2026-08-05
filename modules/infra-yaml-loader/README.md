# infra-yaml-loader

Loads and merges MetaCloud infrastructure YAML setup definitions for driver modules.

## What it does

- merges root `_.yaml` and folder `**/_.yaml` shared configs into each workspace file
- resolves YAML anchors/aliases across merged layers (same model as driver `yamldecode(join(...))`)
- filters out shared-config files, `metacloud.yaml`, generated `_terragrunt/` / `_terraform/` paths, and `.terraform` folders
- keeps only workspaces with `source` (and `version` for registry/remote sources; local relative paths default to `local`)
- auto-detects linked workspace paths from `$${setup["output"]}` and `$${setup.field}` interpolation

## Linked workspaces

A workspace dependency is always **declared**, never inferred from the directory
layout. There are two ways to declare one, and they are equivalent for the
consuming driver:

```yaml
# 1. explicit, for a dependency with no value reference (ordering only)
linked_workspaces:
  - 0-accounts/root/iam-prod
  - 1-environments/prod/rds-postgres

# 2. a reference, which already names the workspace it depends on
providers:
  - name: kubernetes
    variables:
      host: $${1-environments/dev/eks.cluster_host}
```

This submodule detects the second form across `variables` and `providers` and
returns it in `auto_detected_linked_workspaces`; drivers merge it with the
explicit list.

Directory names carry no meaning here. Repositories order paths differently
(`2-products/<product>/<env>/...`, `2-products/<env>/<product>/...`, or the
environment folded into the product folder name), and a setup may depend on any
environment workspace — `eks`, `rds-postgres`, `dns` — so a dependency that is not
referenced anywhere has to be listed explicitly.

## Usage

Driver modules call this submodule from the Terraform registry:

```hcl
module "infra_yaml_loader" {
  source  = "dasmeta/generic/renderer//modules/infra-yaml-loader"
  version = "1.1.0"

  yamldir = var.yamldir
}
```

The registry source works when the driver is the root module or when it is loaded
as a nested local module from `_metacloud.tf`.

## Outputs

- `yaml_files` — workspace documents used by drivers
- `auto_detected_linked_workspaces` — linked paths detected from interpolation references
- `yaml_files_raw` — pre-filter merged documents (debug/validation)
- `yaml_paths` — sorted workspace path keys
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_yamldir"></a> [yamldir](#input\_yamldir) | Directory containing infrastructure YAML module definitions. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auto_detected_linked_workspaces"></a> [auto\_detected\_linked\_workspaces](#output\_auto\_detected\_linked\_workspaces) | Linked workspace paths auto-detected from ${...} interpolation in variables and providers. |
| <a name="output_folders_shared_yaml"></a> [folders\_shared\_yaml](#output\_folders\_shared\_yaml) | Folder-level shared YAML content keyed by folder path. |
| <a name="output_yaml_files"></a> [yaml\_files](#output\_yaml\_files) | Resolved workspace YAML after shared-config merge and source/version filtering. |
| <a name="output_yaml_files_raw"></a> [yaml\_files\_raw](#output\_yaml\_files\_raw) | Merged YAML documents keyed by workspace path before source/version filtering. |
| <a name="output_yaml_paths"></a> [yaml\_paths](#output\_yaml\_paths) | Workspace paths derived from YAML files. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
