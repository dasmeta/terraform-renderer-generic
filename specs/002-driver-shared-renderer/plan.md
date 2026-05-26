# Shared Driver Renderer Convergence Plan

- replace `module_source`, `module_version`, `module_vars`, and
  `module_providers` with grouped `module_config`
- move remaining generic rendering complexity out of
  `terraform-tfe-cloud/modules/workspace` into `terraform-renderer-generic`
- migrate `terramate-poc` first to keep one consumer green while changing the
  shared interface
- migrate `terraform-tfe-cloud/modules/workspace` second using a local relative
  source path to the shared renderer
- verify the shared renderer example and both driver consumers after the change
