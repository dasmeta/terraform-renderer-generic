resource "local_file" "this" {
  for_each = { for file in local.files_to_generate_with_optional_providers : file.name => file }

  content  = each.value.content
  filename = "${trimsuffix(var.target_dir, "/")}/${local.setup_path}/${each.value.name}"
}
