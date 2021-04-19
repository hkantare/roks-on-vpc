##############################################################################
# Key Protect
##############################################################################

resource ibm_resource_instance kms {
  name              = "${var.unique_id}-kms"
  location          = var.ibm_region
  plan              = var.kms_plan
  resource_group_id = var.resource_group_id
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
  resource_group_id = var.resource_group_id != "" ? var.resource_group_id : null

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