# Tasks

- [x] Add an empty YAML fixture under `modules/infra-yaml-loader/examples/basic/fixtures/empty-yaml`.
- [x] Add an executable example module call for the empty-YAML fixture.
- [x] Add a check block asserting empty YAML files produce no loader workspace paths.
- [x] Reproduce the original `coalesce()` failure with the new example case.
- [x] Replace the unsafe `coalesce()` normalization with safe version resolution.
- [x] Run `terraform fmt` for `terraform-renderer-generic`.
- [x] Validate the loader module and example.
- [x] Validate temporary downstream usage for Terragrunt, Terramate, and TFE Cloud consumers.
- [ ] Publish a new renderer version after merge to `main`.
- [ ] Update downstream module pins after the renderer release is available.
