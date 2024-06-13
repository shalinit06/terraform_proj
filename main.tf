provider "aws" {
  region = var.region
}

# Loop through environments and sub-environments to create resources dynamically
locals {
  environments = {
    "dev" = {
      "natasha" = {
        objects = [
          { type = "container", name = "svc1", count = 2 },
          { type = "db", name = "rdb", count = 1 }
        ]
      }
    }
    "prod" = {
      objects = [
        { type = "container", name = "svc1", count = 3 }
      ]
    }
  }
}

# Dynamically create resources based on the environment structure
resource "terraform_data" "environment_objects" {
  for_each = local.environments

  dynamic "subenv" {
    for_each = lookup(each.value, "subenvs", {})

    content {
      name = subenv.key

      dynamic "object" {
        for_each = subenv.value.objects

        content {
          input = {
            name  = "${each.key}-${subenv.key}-${lookup(object.value, "type", "")}-${object.value.name}"
            type  = object.value.type
            count = object.value.count
          }
        }
      }
    }
  }
}

