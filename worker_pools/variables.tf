##############################################################################
# Worker Pool Variables
##############################################################################

variable pool_list {
    description = "List of maps describing pool data"
}

variable vpc_id {
    description = "VPC where the cluster is provisioned"
}

variable resource_group_id {
    description = "ID of the group where the pool will be provisioned"
    default     = ""
}

variable cluster_name_id {
    description = "Name or ID of cluster where pool will be provisioned"
}

variable subnets {
  description = "List of maps containing data for the subnet id. The subnets must contain: `id` the id of the subnet and `zone` the zone number of the subnet (1,2,3). Any number of different subnets can be added"
}

variable ibm_region {
    description = "IBM Cloud region where all resources will be deployed"
}

variable entitlement {
    description = "If you purchased an IBM Cloud Cloud Pak that includes an entitlement to run worker nodes that are installed with OpenShift Container Platform, enter entitlement to create your cluster with that entitlement so that you are not charged twice for the OpenShift license. Note that this option can be set only when you create the cluster. After the cluster is created, the cost for the OpenShift license occurred and you cannot disable this charge."
    type        = string
    default     = "cloud_pak"
}

##############################################################################