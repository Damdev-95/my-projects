provider "aws" {
  region = "eu-west-1"
}

module "app_vpc" {
  source = "./modules/vpc"
  
  vpc_cidr           = "10.10.100.0/24"
  vpc_name           = "solace-app-vpc"
  public_subnet_cidr = "10.10.100.0/25"
}

module "backend_vpc" {
  source = "./modules/vpc"
  
  vpc_cidr           = "172.30.100.0/24"
  vpc_name           = "solace-backend-vpc"
  public_subnet_cidr = "172.30.100.0/25"
}

module "database_vpc" {
  source = "./modules/vpc"
  
  vpc_cidr           = "192.168.100.0/24"
  vpc_name           = "solace-database-vpc"
  public_subnet_cidr = "192.168.100.0/25"
}

# Then create the Transit Gateway
module "transit_gateway" {
  source = "./modules/transit_gateway"
  
  vpc_attachments = [
    {
      vpc_id    = module.app_vpc.vpc_id
      subnet_id = module.app_vpc.public_subnet_id
      vpc_name  = "app"
      vpc_cidr  = "10.10.100.0/24"
    },
    {
      vpc_id    = module.backend_vpc.vpc_id
      subnet_id = module.backend_vpc.public_subnet_id
      vpc_name  = "backend"
      vpc_cidr  = "172.30.100.0/24"
    },
    {
      vpc_id    = module.database_vpc.vpc_id
      subnet_id = module.database_vpc.public_subnet_id
      vpc_name  = "database"
      vpc_cidr  = "192.168.100.0/24"
    }
  ]
}

# Add Transit Gateway Routes to VPC Route Tables
resource "aws_route" "app_to_database" {
  route_table_id         = module.app_vpc.route_table_id
  destination_cidr_block = "192.168.100.0/24"  # Route to Database VPC
  transit_gateway_id     = module.transit_gateway.transit_gateway_id
}

resource "aws_route" "backend_to_app" {
  route_table_id         = module.backend_vpc.route_table_id
  destination_cidr_block = "10.10.100.0/24"  # Route to App VPC
  transit_gateway_id     = module.transit_gateway.transit_gateway_id
}

resource "aws_route" "backend_to_database" {
  route_table_id         = module.backend_vpc.route_table_id
  destination_cidr_block = "192.168.100.0/24"  # Route to Database VPC
  transit_gateway_id     = module.transit_gateway.transit_gateway_id
}

resource "aws_route" "database_to_backend" {
  route_table_id         = module.database_vpc.route_table_id
  destination_cidr_block = "172.30.100.0/24"  # Route to Backend VPC
  transit_gateway_id     = module.transit_gateway.transit_gateway_id
}


# EC2 Instance Modules
module "app_instance" {
  source = "./modules/ec2_instance"

  subnet_id     = module.app_vpc.public_subnet_id
  instance_name = "solace-app-instance"
  key_name      = "dev"
}

module "backend_instance" {
  source = "./modules/ec2_instance"

  subnet_id     = module.backend_vpc.public_subnet_id
  instance_name = "solace-backend-instance"
  key_name      = "dev"
}

module "database_instance" {
  source        = "./modules/ec2_instance"
  subnet_id     = module.database_vpc.public_subnet_id
  instance_name = "solace-database-instance"
  key_name      = "dev"
}