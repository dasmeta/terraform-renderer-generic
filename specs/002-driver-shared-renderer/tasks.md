# Shared Driver Renderer Convergence Tasks

- [x] Refactor `terraform-renderer-generic` to accept grouped `module_config`.
- [x] Keep generic file rendering behavior green in the renderer example.
- [x] Migrate `terramate-poc` to the new shared renderer interface.
- [x] Move remaining generic rendering logic from
      `terraform-tfe-cloud/modules/workspace` into the shared renderer.
- [x] Migrate `terraform-tfe-cloud/modules/workspace` to the shared renderer via
      local relative source path.
- [x] Verify renderer, Terramate driver, and Terraform Cloud workspace tests.
