output "vpc_ids" {
  value = {
    app      = module.app_vpc.vpc_id
    backend  = module.backend_vpc.vpc_id
    database = module.database_vpc.vpc_id
  }
}

output "instance_ids" {
  value = {
    app      = module.app_instance.instance_id
    backend  = module.backend_instance.instance_id
    database = module.database_instance.instance_id
  }
}