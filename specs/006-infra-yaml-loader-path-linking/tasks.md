# Tasks

- [x] Reproduce the `regex()` tuple interpolation failure with a tiered workspace path.
- [x] Confirm HCL `&&` short-circuits, ruling out the reported non-matching-path failure.
- [x] Review five managed infrastructure repositories for the convention.
- [x] Confirm no managed repository uses a `setups/` directory or a uniform tier order.
- [x] Confirm the setup-to-cluster case is already covered by interpolation references.
- [x] Confirm `terraform-tfe-cloud` does not consume `auto_detected_linked_workspaces`.
- [x] Add tiered fixtures under `modules/infra-yaml-loader/examples/basic/fixtures/tiered`.
- [x] Add check blocks for reference-based linking and for absence of path-based linking.
- [x] Remove `path_inferred_linked_workspaces` and simplify `auto_detected_linked_workspaces`.
- [x] Raise the renderer root `required_version` to `~> 1.8`.
- [x] Update loader, renderer, and Terramate documentation.
- [x] Run `terraform fmt` and validate the loader module, loader example, and renderer example.
- [ ] Publish a new renderer version after merge to `main`.
- [ ] Update downstream driver pins and version constraints after the renderer release is available.
- [ ] Declare explicit setup-to-cluster links in `dasmeta-infrastructure` and drop its `handler_version` pin.
