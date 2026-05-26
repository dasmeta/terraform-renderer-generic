variable "name" {
  type        = string
  description = "Generated setup folder name and unique identifier."
}

variable "setup_path" {
  type        = string
  default     = null
  description = "Optional relative output path for the generated setup. When unset, the normalized name is used."
}

variable "module_config" {
  type = object({
    source    = string
    version   = string
    variables = optional(any, {})
    providers = optional(any, [])
  })
  description = "Grouped Terraform module configuration rendered into generated files."
}

variable "target_dir" {
  type        = string
  default     = "./"
  description = "Parent directory where the generated setup folder will be created."
}

variable "terraform" {
  type = object({
    version = optional(string, "~> 1.3")
    backend = optional(object({
      name    = string
      configs = optional(any, {})
      }), {
      name    = null
      configs = null
    })
    cloud = optional(object({
      organization = string
    }), null)
  })
  default     = {}
  description = "Grouped Terraform runtime configuration rendered into generated versions.tf."
}

variable "linked_setups" {
  type        = any
  default     = {}
  description = "Optional linked setup remote-state definitions used for generated output wiring in main.tf."
}

variable "provider_custom_var_blocks" {
  type        = any
  default     = {}
  description = "Optional provider-specific custom blocks merged into provider rendering. Useful for blocks like aws.default_tags."
}

variable "provider_default_tags" {
  type        = any
  default     = {}
  description = "Optional provider-specific default tag settings. Currently supports aws default_tags injection."
}

variable "linked_setup_result_mapping" {
  type        = any
  default     = null
  description = "Optional explicit linked-setup result mapping used for interpolation replacement. When null, the module derives remote-state mappings from linked_setups."
}

variable "main_tf_extra_content" {
  type        = string
  default     = null
  description = "Optional extra Terraform content inserted before the generated module block in main.tf."
}

variable "output" {
  type = object({
    enabled   = optional(bool, true)
    sensitive = optional(bool, null)
  })
  default     = {}
  description = "Optional generated outputs.tf configuration. By default the module renders output \"results\" with value = module.this."
}

variable "generated_by_module" {
  type        = string
  default     = "dasmeta/terraform-renderer-generic"
  description = "Module identifier written into generated README.md."
}
