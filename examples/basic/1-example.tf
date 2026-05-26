module "this" {
  source = "../.."

  name       = "example-stack"
  target_dir = "./output"
  module_config = {
    source    = "dasmeta/empty/null"
    version   = "1.2.2"
    variables = {}
    providers = []
  }
}
