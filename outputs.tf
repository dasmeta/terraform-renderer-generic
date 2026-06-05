output "generated_files" {
  value       = [for name in sort(keys(local_file.this)) : local_file.this[name].filename]
  description = "Paths of generated files written to the target directory."
}

output "generated_dir" {
  value       = "${trimsuffix(var.target_dir, "/")}/${local.setup_path}"
  description = "Generated setup directory path."
}

output "rendered_name" {
  value       = local.name_specials_clean
  description = "Normalized generated setup name."
}

output "effective_linked_setups" {
  value       = local.effective_linked_setup_names
  description = "Effective linked setup names after merging explicit and auto-detected references."
}
