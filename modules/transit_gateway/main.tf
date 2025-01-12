resource "aws_ec2_transit_gateway" "tgw" {
  description = "Transit Gateway for Solace App"
  
  tags = {
    Name = "solace-transit-gateway"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment" {
  count = length(var.vpc_attachments)

  subnet_ids         = [var.vpc_attachments[count.index].subnet_id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id            = var.vpc_attachments[count.index].vpc_id

  tags = {
    Name = "${var.vpc_attachments[count.index].vpc_name}-tgw-attachment"
  }
}

# Create separate route tables for each VPC attachment
resource "aws_ec2_transit_gateway_route_table" "app_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = {
    Name = "app-tgw-rt"
  }
}

resource "aws_ec2_transit_gateway_route_table" "backend_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = {
    Name = "backend-tgw-rt"
  }
}

resource "aws_ec2_transit_gateway_route_table" "database_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = {
    Name = "database-tgw-rt"
  }
}

# Associate route tables with attachments
resource "aws_ec2_transit_gateway_route_table_association" "app_rt_assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.app_rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "backend_rt_assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment[1].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.backend_rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "database_rt_assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment[2].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.database_rt.id
}

# Configure routes in transit gateway route tables
# App VPC can only reach Database VPC
resource "aws_ec2_transit_gateway_route" "app_to_database" {
  destination_cidr_block         = var.vpc_attachments[2].vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment[2].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.app_rt.id
}

# Database VPC can only reach Backend VPC
resource "aws_ec2_transit_gateway_route" "database_to_backend" {
  destination_cidr_block         = var.vpc_attachments[1].vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment[1].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.database_rt.id
}

# Backend VPC can reach both App and Database VPCs
resource "aws_ec2_transit_gateway_route" "backend_to_app" {
  destination_cidr_block         = var.vpc_attachments[0].vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.backend_rt.id
}

resource "aws_ec2_transit_gateway_route" "backend_to_database" {
  destination_cidr_block         = var.vpc_attachments[2].vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment[2].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.backend_rt.id
}