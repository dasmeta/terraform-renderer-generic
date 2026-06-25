# Implementation Plan

## Scope

Introduce shared YAML fetch/merge logic as a renderer submodule and document it
for driver consumption.

## Steps

1. Add `modules/infra-yaml-fetched` with:
   - shared-config merge via `yamldecode(join(...))`
   - workspace filtering rules aligned with MetaCloud drivers
   - linked workspace auto-detection from interpolation
2. Add example fixtures and check blocks under
   `modules/infra-yaml-fetched/examples/basic`.
3. Document the submodule in:
   - `modules/infra-yaml-fetched/README.md`
   - root `README.md`
4. Publish via semantic release after merge to `main`.

## Validation

- `terraform -chdir=modules/infra-yaml-fetched/examples/basic init -backend=false`
- `terraform -chdir=modules/infra-yaml-fetched/examples/basic plan -refresh=false`
