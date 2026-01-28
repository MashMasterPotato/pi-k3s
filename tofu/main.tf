terraform {
  required_version = ">= 1.6.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0.0"
    }
  }
}

resource "local_file" "inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content = templatefile("${path.module}/templates/inventory.ini.tmpl", {
    pi_host = var.pi_host
    pi_user = var.pi_user
  })
}

resource "null_resource" "provision" {
  triggers = {
    inventory_sha = sha256(local_file.inventory.content)
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/../ansible && ansible-playbook -i inventory.ini site.yml"
  }

  depends_on = [local_file.inventory]
}

