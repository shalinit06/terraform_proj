output "environment_objects" {
  value = { for k, v in terraform_data.environment_objects : k => v }
}

