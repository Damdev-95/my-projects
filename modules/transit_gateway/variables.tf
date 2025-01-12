variable "vpc_attachments" {
  type = list(object({
    vpc_id     = string
    subnet_id  = string
    vpc_name   = string
    vpc_cidr   = string
  }))
  description = "List of VPC attachments for the transit gateway"
}