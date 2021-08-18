##############################################################################
# Resource Group
##############################################################################

data ibm_resource_group resource_group {
  name = var.resource_group
}

##############################################################################


##############################################################################
# VPC Data
#############################################################################

data ibm_is_vpc vpc {
  name = var.vpc_name
}

#############################################################################


#############################################################################
# Get Subnet Data
# > If the subnets cannot all be gotten by name, replace the `name`
#   field with the `identifier` field and get the subnets by ID instead
#   of by name.
#############################################################################

data ibm_is_subnet subnets {
  count = length(var.subnet_names)
  name  = var.subnet_names[count.index]
}

#############################################################################


##############################################################################
# Resources
##############################################################################
# Key Protect
##############################################################################

resource ibm_resource_instance kms {
  name              = "${var.unique_id}-kms"
  location          = var.ibm_region
  plan              = var.kms_plan
  resource_group_id = data.ibm_resource_group.resource_group.id
  service           = "kms"
  service_endpoints = var.service_endpoints
}

##############################################################################

##############################################################################
# Key Protect Root Key
##############################################################################

resource ibm_kms_key root_key {
  instance_id  = ibm_resource_instance.kms.guid
  key_name     = var.kms_root_key_name
  standard_key = false
}

##############################################################################

##############################################################################
# COS Instance
##############################################################################

resource ibm_resource_instance cos {
  name              = "${var.unique_id}-cos"
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
  resource_group_id = data.ibm_resource_group.resource_group.id != "" ? data.ibm_resource_group.resource_group.id : null

  parameters = {
    service-endpoints = "private"
  }

  timeouts {
    create = "1h"
    update = "1h"
    delete = "1h"
  }

}

##############################################################################

##############################################################################
# Policy for KMS
##############################################################################

resource ibm_iam_authorization_policy cos_policy {
  source_service_name         = "cloud-object-storage"
  source_resource_instance_id = ibm_resource_instance.cos.id
  target_service_name         = "kms"
  target_resource_instance_id = ibm_resource_instance.kms.id
  roles                       = ["Reader"]
}

##############################################################################
##############################################################################

##############################################################################
# Create IKS on VPC Cluster
##############################################################################

resource ibm_container_vpc_cluster cluster {

  name              = "${var.unique_id}-roks-cluster"
  vpc_id            = data.ibm_is_vpc.vpc.id
  resource_group_id = data.ibm_resource_group.resource_group.id
  flavor            = var.machine_type
  worker_count      = var.workers_per_zone
  kube_version      = var.kube_version != "" ? var.kube_version : null
  tags              = var.tags
  wait_till         = var.wait_till
  entitlement       = var.entitlement
  cos_instance_crn  = ibm_resource_instance.cos.id

  dynamic zones {
    for_each = data.ibm_is_subnet.subnets
    content {
      subnet_id = zones.value.id
      name      = zones.value.zone
    }
  }

  disable_public_service_endpoint = var.disable_public_service_endpoint

  kms_config {
    instance_id      = ibm_resource_instance.kms.guid
    crk_id           = ibm_kms_key.root_key.key_id
    private_endpoint = var.kms_private_service_endpoint
  }

}

##############################################################################

##############################################################################
# Worker Pools
##############################################################################

resource ibm_container_vpc_worker_pool pool {

    count              = length(var.worker_pools)
    vpc_id             = var.vpc_id
    resource_group_id  = data.ibm_resource_group.resource_group.id
    entitlement        = var.entitlement
    cluster            = ibm_container_vpc_cluster.cluster.id
    worker_pool_name   = var.pool_list[count.index].pool_name
    flavor             = var.pool_list[count.index].machine_type
    worker_count       = var.pool_list[count.index].workers_per_zone

    dynamic zones {
        for_each = data.ibm_is_subnet.subnets
        content {
            subnet_id = zones.value.id
            name      = zones.value.zone
        }
    }


}


##############################################################################