output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.tgw.id
  description = "ID of the created transit gateway"
}

output "app_rt_id" {
  value = aws_ec2_transit_gateway_route_table.app_rt.id
}

output "backend_rt_id" {
  value = aws_ec2_transit_gateway_route_table.backend_rt.id
}

output "database_rt_id" {
  value = aws_ec2_transit_gateway_route_table.database_rt.id
}