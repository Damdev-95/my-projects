variable "subnet_id" {
  type        = string
  description = "Subnet ID where the instance will be launched"
}

variable "instance_name" {
  type        = string
  description = "Name tag for the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
  default     = "t2.micro"
}

variable "key_name" {
  type        = string
  description = "Name of the key pair to use for the instance"
  default     = "dev"  # Default to dev key pair
}