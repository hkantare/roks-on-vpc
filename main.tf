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

module resources {
  source            = "./resources"

  # Account Variables
  unique_id         = var.unique_id
  ibm_region        = var.ibm_region
  resource_group_id = data.ibm_resource_group.resource_group.id

  # Resource Variables
  service_endpoints = var.service_endpoints
  kms_plan          = var.kms_plan
  kms_root_key_name = var.kms_root_key_name
  cos_plan          = var.cos_plan
}

##############################################################################