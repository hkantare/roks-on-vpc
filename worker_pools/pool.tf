##############################################################################
# Worker Pool
##############################################################################

resource ibm_container_vpc_worker_pool pool {

    count              = length(var.pool_list)
    vpc_id             = var.vpc_id
    resource_group_id  = var.resource_group_id
    entitlement        = var.entitlement
    cluster            = var.cluster_name_id
    worker_pool_name   = var.pool_list[count.index].pool_name
    flavor             = var.pool_list[count.index].machine_type
    worker_count       = var.pool_list[count.index].workers_per_zone

    dynamic zones {
        for_each = var.subnets
        content {
            subnet_id = zones.value.id
            name      = zones.value.zone
        }
    }


}

##############################################################################