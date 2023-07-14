#0. Create IAM Instance Profile With Attached IAM Role

resource "aws_iam_instance_profile" "profile" {
  name = "${var.project_name}-profile"
  role = var.role
}

