variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "vpc_name" {
  type        = string
  description = "Name tag for the VPC"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for the public subnet"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone for the subnet"
  default     = "eu-west-1a"
}

variable "destination_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks for route table"
  default     = []
}