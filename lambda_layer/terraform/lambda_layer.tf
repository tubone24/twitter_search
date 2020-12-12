####################################################
# pandas_layer
####################################################
resource "aws_lambda_layer_version" "requests_layer" {
  depends_on = [null_resource.pip_install]

  filename   = "requests.zip"
  layer_name = "requests"

  compatible_runtimes = ["python3.7"]
  description = "Requests layer"
}

locals {
  requirements_file_path = "requirements/requests_layer/requirements.txt"
}

resource "null_resource" "pip_install" {
  triggers = {
    requirements_text = data.template_file.requirements_text.rendered
  }

  provisioner "local-exec" {
    command = "rm -rf python/"
  }

  provisioner "local-exec" {
    command = "rm -rf requests.zip"
  }

  provisioner "local-exec" {
    command = "python install -r ${local.requirements_file_path} -t ./python"
  }

  provisioner "local-exec" {
    command = "zip -r requests.zip  python/"
  }
}

data "template_file" "requirements_text" {
  template = file(local.requirements_file_path)
}