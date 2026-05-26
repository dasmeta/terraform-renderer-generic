locals {
  expected_dir = "./output/example-stack"
  expected_files = sort([
    "${local.expected_dir}/README.md",
    "${local.expected_dir}/main.tf",
    "${local.expected_dir}/outputs.tf",
    "${local.expected_dir}/versions.tf",
  ])
}

check "generated_directory_matches_fixture" {
  assert {
    condition     = module.this.generated_dir == local.expected_dir
    error_message = "Generated directory does not match the expected example output path."
  }
}

check "generated_files_match_fixture" {
  assert {
    condition     = sort(module.this.generated_files) == local.expected_files
    error_message = "Generated file list does not match the expected renderer output."
  }
}
