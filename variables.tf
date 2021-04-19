##############################################################################
# Account variables
##############################################################################

variable ibmcloud_api_key {
    description = "The IBM Cloud platform API key needed to deploy IAM enabled resources"
    type        = string
}

variable ibm_region {
    description = "IBM Cloud region where all resources will be deployed"
    type        = string

    validation  {
      error_message = "Must use an IBM Cloud region. Use `ibmcloud regions` with the IBM Cloud CLI to see valid regions."
      condition     = can(
        contains([
          "au-syd",
          "jp-tok",
          "eu-de",
          "eu-gb",
          "us-south",
          "us-east"
        ], var.ibm_region)
      )
    }
}

variable resource_group {
    description = "Name of resource group where all infrastructure will be provisioned"
    type        = string
    default     = "asset-development"

    validation  {
      error_message = "Unique ID must begin and end with a letter and contain only letters, numbers, and - characters."
      condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.resource_group))
    }
}

variable unique_id {
    description = "A unique identifier need to provision resources. Must begin with a letter"
    type        = string
    default     = "asset-roks"

    validation  {
      error_message = "Unique ID must begin and end with a letter and contain only letters, numbers, and - characters."
      condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.unique_id))
    }
}


##############################################################################


##############################################################################
# VPC Variables
##############################################################################

variable vpc_name {
    description = "Name of VPC where cluster is to be created"
    type        = string

    validation  {
        error_message = "VPC Name must begin and end with a letter and contain only letters, numbers, and - characters."
        condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.vpc_name))
    }

}

variable subnet_names {
    description = "List of subnet names"
    type        = list(string)
    default     = [
        "asset-multizone-zone-1-subnet-1",
        "asset-multizone-zone-1-subnet-2",
        "asset-multizone-zone-1-subnet-3"
    ]

    validation  {
        error_message = "Subnet names must match the regex `^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$`."
        condition     = length([
            for name in var.subnet_names:
            false if !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", name))
        ]) == 0
    }

    validation {
        error_message = "Subnet names must include at least one subnet."
        condition     = length(var.subnet_names) > 0
    }

    validation {
        error_message = "Subnet names cannot contain any duplicate names."
        condition     = length(distinct(var.subnet_names)) == length(var.subnet_names)
    }

}
##############################################################################


##############################################################################
# Cluster Variables
##############################################################################

variable machine_type {
    description = "The flavor of VPC worker node to use for your cluster. Use `ibmcloud ks flavors` to find flavors for a region."
    type        = string
    default     = "bx2.4x16"
}

variable workers_per_zone {
    description = "Number of workers to provision in each subnet"
    type        = number
    default     = 2

    validation {
        error_message = "Each zone must contain at least 2 workers."
        condition     = var.workers_per_zone >= 2
    }
}

variable disable_public_service_endpoint {
    description = "Disable public service endpoint for cluster"
    type        = bool
    default     = false
}

variable entitlement {
    description = "If you purchased an IBM Cloud Cloud Pak that includes an entitlement to run worker nodes that are installed with OpenShift Container Platform, enter entitlement to create your cluster with that entitlement so that you are not charged twice for the OpenShift license. Note that this option can be set only when you create the cluster. After the cluster is created, the cost for the OpenShift license occurred and you cannot disable this charge."
    type        = string
    default     = "cloud_pak"
}

variable kube_version {
    description = "Specify the Kubernetes version, including the major.minor version. To see available versions, run `ibmcloud ks versions`."
    type        = string
    default     = "4.5.35_openshift"

    validation {
        error_message = "To create a ROKS cluster, the kube version must include `openshift`."
        condition     = can(regex(".*openshift", var.kube_version))
    }
}

variable wait_till {
    description = "To avoid long wait times when you run your Terraform code, you can specify the stage when you want Terraform to mark the cluster resource creation as completed. Depending on what stage you choose, the cluster creation might not be fully completed and continues to run in the background. However, your Terraform code can continue to run without waiting for the cluster to be fully created. Supported args are `MasterNodeReady`, `OneWorkerNodeReady`, and `IngressReady`"
    type        = string
    default     = "IngressReady"

    validation {
        error_message = "`wait_till` value must be one of `MasterNodeReady`, `OneWorkerNodeReady`, or `IngressReady`."
        condition     = contains([
            "MasterNodeReady",
            "OneWorkerNodeReady",
            "IngressReady"
        ], var.wait_till)
    }
}

variable tags {
    description = "A list of tags to add to the cluster"
    type        = list(string)
    default     = []

    validation  {
        error_message = "Tags must match the regex `^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$`."
        condition     = length([
            for name in var.tags:
            false if !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", name))
        ]) == 0
    }
}

variable worker_pools {
    description = "List of maps describing worker pools"

    type        = list(object({
        pool_name        = string
        machine_type     = string
        workers_per_zone = number
    }))

    default     = [
        {
            pool_name        = "dev"
            machine_type     = "cx2.8x16"
            workers_per_zone = 2
        },
        {
            pool_name        = "test"
            machine_type     = "mx2.4x32"
            workers_per_zone = 2
        }
    ]

    validation  {
        error_message = "Worker pool names must match the regex `^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$`."
        condition     = length([
            for pool in var.worker_pools:
            false if !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", pool.pool_name))
        ]) == 0
    }

    validation {
        error_message = "Worker pools cannot have duplicate names."
        condition     = length(distinct([
            for pool in var.worker_pools:
            pool.pool_name
        ])) == length(var.worker_pools)
    }

    validation {
        error_message = "Worker pools must have at least two workers per zone."
        condition     = length([
            for pool in var.worker_pools:
            false if pool.workers_per_zone < 2
        ]) == 0
    }

}

##############################################################################

##############################################################################
# Resource Variables
##############################################################################

variable service_endpoints {
    description = "Service endpoints for resource instances. Can be `public`, `private`, or `public-and-private`."
    type        = string
    default     = "private"

    validation {
        error_message = "Service endpoints must be `public`, `private`, or `public-and-private`."
        condition = contains([
            "private",
            "public",
            "public-and-private"
        ], var.service_endpoints)
    }
}

variable kms_plan {
    description = "Plan for Key Protect"
    type        = string
    default     = "tiered-pricing"  
}

variable kms_root_key_name {
    description = "Name of the root key for Key Protect instance"
    type        = string
    default     = "root-key"

    validation {
        error_message = "Key protect root key name  must match the regex `^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$."
        condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.kms_root_key_name))
    }
}

variable kms_private_service_endpoint {
    description = "Use private service endpoint for Key Protect instance"
    type        = bool
    default     = true
}

variable cos_plan {
    description = "Plan for Cloud Object Storage instance"
    type        = string
    default     = "standard"
}

##############################################################################