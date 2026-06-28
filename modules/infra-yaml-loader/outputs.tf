output "yaml_files_raw" {
  value       = local.yaml_files_raw
  description = "Merged YAML documents keyed by workspace path before source/version filtering."
}

output "yaml_files" {
  value       = local.yaml_files
  description = "Resolved workspace YAML after shared-config merge and source/version filtering."
}

output "yaml_paths" {
  value       = sort(keys(local.yaml_files))
  description = "Workspace paths derived from YAML files."
}

output "auto_detected_linked_workspaces" {
  value       = local.auto_detected_linked_workspaces
  description = "Linked workspace paths auto-detected from $${...} interpolation in variables and providers."
}

output "folders_shared_yaml" {
  value       = local.folders_shared_yaml
  description = "Folder-level shared YAML content keyed by folder path."
}
