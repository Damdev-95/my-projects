resource "aws_instance" "instance" {
  ami           = "ami-0a422d70f727fe93e"  #Ubuntu 22.04 AMI
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name 

  tags = {
    Name = var.instance_name
  }
}
