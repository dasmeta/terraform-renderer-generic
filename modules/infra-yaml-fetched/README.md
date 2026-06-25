# infra-yaml-fetched

Fetches and merges MetaCloud infrastructure YAML workspace definitions for driver modules.

## What it does

- merges root `_.yaml` and folder `**/_.yaml` shared configs into each workspace file
- resolves YAML anchors/aliases across merged layers (same model as driver `yamldecode(join(...))`)
- filters out shared-config files, `metacloud.yaml`, generated `_terragrunt/` / `_terraform/` paths, and `.terraform` folders
- keeps only workspaces with both `source` and `version`
- auto-detects linked workspace paths from `$${setup["output"]}` and `$${setup.field}` interpolation

## Usage

Driver modules call this with a sibling relative path when the driver is the root module:

```hcl
module "infra_yaml_fetched" {
  count  = var.yaml_files == null ? 1 : 0
  source = "../terraform-renderer-generic/modules/infra-yaml-fetched"
  # source  = "dasmeta/generic/renderer//modules/infra-yaml-fetched"
  # version = "1.1.0"

  yamldir = var.yamldir
}
```

When the driver is loaded as a nested local module (for example from `_metacloud.tf` via `file://`),
Terraform blocks `../` paths that escape the driver package. In that case, fetch YAML at the
`_metacloud.tf` root and pass the outputs into the driver:

```hcl
module "infra_yaml_fetched" {
  source  = "../../../../terraform-renderer-generic/modules/infra-yaml-fetched"
  yamldir = "${path.module}/."
}

module "metacloud" {
  source                          = "../../../../terraform-terragrunt-cli"
  yamldir                         = "${path.module}/."
  yaml_files                      = module.infra_yaml_fetched.yaml_files
  auto_detected_linked_workspaces = module.infra_yaml_fetched.auto_detected_linked_workspaces
}
```

After `dasmeta/generic/renderer` `1.1.0` is published, switch driver and root calls to the registry source.

## Outputs

- `yaml_files` — workspace documents used by drivers
- `auto_detected_linked_workspaces` — linked paths inferred from interpolation
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
