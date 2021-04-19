##############################################################################
# Outputs
##############################################################################

output cos_id {
    description = "ID of COS instance"
    value       = ibm_resource_instance.cos.id
}

##############################################################################

##############################################################################
# Key Protect Outputs
##############################################################################

output kms_guid {
    description = "GUID of Key Protect Instance"
    value       = ibm_resource_instance.kms.guid
}

output ibm_managed_key_id {
    description = "GUID of User Managed Key"
    value       = ibm_kms_key.root_key.key_id
}

##############################################################################
