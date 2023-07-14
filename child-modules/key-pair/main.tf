#1. Key Pair

resource "aws_key_pair" "key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

#2. RSA key of size 4096 bits

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "${var.project_name}-key"
}

