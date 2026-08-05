# Implementation Plan

## Scope

Remove directory-convention linking from `modules/infra-yaml-loader`, and align the
renderer root module with the Terraform version its provider-defined functions
require.

## Current State

- `local.path_inferred_linked_workspaces` hardcodes the
  `2-products/... -> 1-environments/.../cluster` convention and builds the linked
  path through `"...${regex(pattern, path)}..."`. `regex()` with capture groups
  returns a list, so the interpolation fails for every matching path.
- The `if` clause guards with `can(regex(...))` and `contains(...)`. HCL `&&`
  short-circuits, so non-matching paths were already safe; only matching paths
  failed.
- `local.auto_detected_linked_workspaces` concatenates the interpolation-detected
  list with the path-inferred one.
- The loader example fixtures use flat `group-N/module-X` paths, so no existing
  check exercises a tiered layout in either direction.
- `versions.tf` declares `~> 1.3` while `locals.tf` calls
  `provider::deepmerge::mergo`, which needs Terraform 1.8 or newer.

## Investigation

Reviewed the managed setups before choosing between fixing and removing:

| repository | product path shape | `setups/` dir | how environment links are declared |
|---|---|---|---|
| `spm/playerplus-iac` | `2-products/<product>/<name>` | no | explicit + reference |
| `von-poll/iac/terraform-cloud` | `2-product/<env>/<name>` | no | reference |
| `payconomy/infrastructure` | `2-products/<product>/<env>/<name>` | no | explicit + reference |
| `sela-ai/infrastructure` | `2-products/<env>/<product>/<name>` | no | explicit + reference |
| `buycycle/infrastructure` | `2-products/<product-with-env>/<name>` | no | reference |

The convention matches no managed repository, the path shapes disagree with each
other, and the case it targeted is already served by the reference form. Removal,
not repair or parameterization.

## Steps

1. Add tiered fixtures to the loader example: an environment workspace, a product
   workspace that references it from a provider config, and a product workspace
   that references nothing.
2. Add check blocks asserting the reference produces a link and that path shape
   alone produces none.
3. Delete `path_inferred_linked_workspaces` and reduce
   `auto_detected_linked_workspaces` to the interpolation-detected list.
4. Update loader, renderer, and Terramate documentation to state that links are
   declared rather than inferred.
5. Raise the renderer root `required_version` to `~> 1.8` and update the generated
   documentation tables.
6. Run loader and renderer validation.

## Validation

- Red check: reproduced the original failure with a tiered path before the change —
  `Invalid template interpolation value: string required, but have tuple.`
- Confirmed HCL `&&` short-circuits, ruling out the reported non-matching-path
  failure mode.
- `terraform -chdir=modules/infra-yaml-loader/examples/basic validate` and `plan` —
  no check warnings
- `terraform -chdir=examples/basic validate` and `plan`
- `terraform fmt -check -recursive .`
- `pre-commit` hooks on commit, including `terraform_docs`

## Breaking Changes

The loader no longer emits links that were never emitted successfully: any path
matching the removed convention aborted evaluation instead. No managed repository
loses a working link.

A repository that intended to rely on the convention must declare the dependency
through the reference it already uses for cluster credentials, or through
`linked_workspaces`.

Consumers pinned below Terraform 1.8 must upgrade before adopting the new renderer
root module release. The loader submodule keeps `~> 1.3` and is unaffected.

## Follow-Up

- Publish a renderer release after merge to `main`.
- Update the `infra-yaml-loader` and `renderer` pins in `terraform-terragrunt-cli`,
  `terraform-terramate-cli`, and `terraform-tfe-cloud`, together with their own
  `~> 1.8` version bumps and spec packages.
- Remove the `handler_version: 2.5.3` pin in `dasmeta-infrastructure` once the
  corrected driver release is available, and declare its setup-to-cluster links.
- Consider exposing `terraform_version` on the `tfe_workspace` resource in
  `terraform-tfe-cloud`. The management workspace currently inherits the HCP
  organization default, which is what placed it on 1.3.0.
