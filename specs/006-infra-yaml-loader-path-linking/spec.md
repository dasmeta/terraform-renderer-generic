# Infra YAML Loader Path Linking Removal

## Why

The shared `infra-yaml-loader` submodule derived linked workspaces from three
sources: explicit YAML `linked_workspaces`, `${...}` interpolation references, and
a hardcoded directory convention linking
`2-products/<product>/<cluster>/setups/<name>` to
`1-environments/<product>/<cluster>/cluster`.

The third source is broken and wrong.

**Broken.** It builds the linked path by interpolating `regex()` results into a
string, but `regex()` with capture groups returns a list, so Terraform fails:

```
Error: Invalid template interpolation value
  Cannot include the given value in a string template: string required, but have tuple.
```

Every path matching the convention triggers it, and no YAML restructuring avoids
it. This reached the published `dasmeta/cloud/tfe` driver and forced a
`handler_version` pin in `dasmeta-infrastructure`.

**Wrong.** A review of the setups managed today — `spm/playerplus-iac`,
`von-poll/iac/terraform-cloud`, `payconomy/infrastructure`,
`sela-ai/infrastructure`, `buycycle/infrastructure` — shows the convention does not
describe how linking works:

- No repository has a `setups/` directory. The rule matches nothing anywhere.
- The tier prefixes exist, but their internal order does not agree:
  `2-products/<product>/<env>/...` in `payconomy`, `2-products/<env>/<product>/...`
  in `sela-ai`, the environment folded into the product folder name
  (`2-products/buycycle-dev-2/...`) in `buycycle`, and singular `2-product/<env>/...`
  in `von-poll`. One regex cannot express these.
- The depended-on workspace is not uniformly named `cluster`. Real dependencies
  point at `eks`, `rds-postgres`, `dns`, and others.
- The case the rule was meant to cover is already covered. A setup that needs
  cluster access writes it as a reference, and the reference already names the
  workspace:

  ```yaml
  providers:
    - name: kubernetes
      variables:
        host: ${1-environments/dev-2/eks.cluster_host}
  ```

- Where a dependency has no value reference, it is declared explicitly:

  ```yaml
  linked_workspaces:
    - 0-accounts/root/iam-prod
    - 1-environments/prod/rds-postgres
  ```

- `terraform-tfe-cloud`, the driver that failed, never reads
  `auto_detected_linked_workspaces`. It uses explicit `linked_workspaces` plus the
  renderer's own per-workspace interpolation detection, so the crash came from a
  code path whose result that driver does not consume.

Both working mechanisms are declaration-driven. Directory names carry no meaning.
Inferring dependencies from path shape is a third, inconsistent contract that
guesses what the other two state.

Separately, the renderer root module calls `provider::deepmerge::mergo` while
declaring `required_version = "~> 1.3"`. Terraform supports provider-defined
functions only from 1.8, so an HCP workspace on 1.3.0 fails while parsing the
module instead of reporting an unsupported Terraform version.

## What

- Remove `path_inferred_linked_workspaces` from `modules/infra-yaml-loader`.
- Keep `auto_detected_linked_workspaces` as the interpolation-detected list only.
  Its type and meaning for drivers are unchanged.
- Do not replace the convention with a configurable equivalent. Configurability
  would preserve a mechanism that no managed setup uses and that duplicates the
  two declared ones.
- Raise the renderer root module to `required_version = "~> 1.8"` to match its use
  of provider-defined functions.

## Acceptance Criteria

- no workspace path can abort loader evaluation, whatever the directory layout
- a `${path.output}` reference inside `variables` or `providers` still produces a
  linked workspace
- a workspace with no explicit entry and no reference produces no links, whatever
  its path looks like
- explicit `linked_workspaces` handling is unchanged
- the loader example covers both outcomes with a tiered fixture layout
- the renderer root module declares a Terraform version supporting
  `provider::deepmerge::mergo`
- the loader submodule keeps `~> 1.3`, since it uses no provider functions

## Notes

- The ticket also reports that the guard evaluates unsafe `regex()` calls for
  non-matching setup paths. That does not reproduce: HCL `&&` short-circuits, so
  non-matching paths were unaffected. The tuple interpolation on matching paths was
  the entire defect, which is why only repositories using a `setups/` layout broke.
- Repositories that relied on the implicit setup-to-cluster link — in practice only
  `dasmeta-infrastructure` — must declare it, either through the reference they
  already use for cluster credentials or through `linked_workspaces`. This is the
  same contract every other managed repository follows.
- Raising the constraint for generated child stacks is out of scope. The renderer
  `terraform.version` input default stays `~> 1.3`, because generated workspaces
  call no provider functions and forcing them to 1.8 is a platform policy decision.
- `terraform-renderer-generic` has existing `specs/` packages but no `.specify/`
  command scaffold, so this package follows the established repository-local
  lightweight spec format.
