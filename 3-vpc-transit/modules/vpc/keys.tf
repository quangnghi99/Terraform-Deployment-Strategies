#----------------------------------------------------
## Define your key variable
variable "generated_key_name" {
  type        = string
  default     = "nghi_tf_key.pub"
  description = "Key-pair generated by Terraform"
}
 
## Generate SSH key content using terraform
resource "tls_private_key" "dev_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
 
## Create a AWS key pair using the ssh key generated previously
## Stores the public key in aws and private key in the local system
resource "aws_key_pair" "generated_key" {
  key_name   = var.generated_key_name
  public_key = tls_private_key.dev_key.public_key_openssh
 
  provisioner "local-exec" {    # Generate "nghi_tf_key.pub" in current directory
    command = <<-EOT
      echo '${tls_private_key.dev_key.private_key_pem}' > ./'${var.generated_key_name}'.pem
      chmod 400 ./'${var.generated_key_name}'.pem
    EOT
  }
 
}
#----------------------------------------------------