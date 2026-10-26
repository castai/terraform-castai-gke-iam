output "private_key" {
  description = "Private key of the created service account. Empty unless create_service_account is true and authentication_method is \"service_account_key\"."
  value       = var.create_service_account && var.authentication_method == "service_account_key" ? base64decode(google_service_account_key.castai_key[0].private_key) : ""
  sensitive   = true

  depends_on = [
    # Wait for binding and custom role creation
    # so Service Account will have proper permissions level
    google_project_iam_member.project,
    google_project_iam_member.scoped_project,
    google_project_iam_custom_role.castai_role
  ]
}

output "service_account_id" {
  description = "Account ID of the service account CAST AI uses to access the cluster. Empty when create_service_account is false."
  value       = var.create_service_account ? google_service_account.castai_service_account[0].account_id : ""
}

output "service_account_email" {
  description = "Email of the service account CAST AI uses to access the cluster. In impersonation mode this is the account CAST AI impersonates."
  value       = var.create_service_account ? google_service_account.castai_service_account[0].email : local.service_account_email
}

output "castai_service_account_id" {
  description = "ID of the CAST AI organization service account that performs the impersonation, as returned by the castai_impersonation_service_account data source. Empty unless authentication_method is \"impersonation\"."
  value       = var.authentication_method == "impersonation" ? data.castai_impersonation_service_account.gke[0].id : ""
}

output "castai_service_account_email" {
  description = "Email of the CAST AI organization service account that performs the impersonation. Empty unless authentication_method is \"impersonation\"."
  value       = var.authentication_method == "impersonation" ? data.castai_impersonation_service_account.gke[0].email : ""
}

output "target_service_account_email" {
  description = "Email of the service account in the GCP project that CAST AI impersonates. Empty unless authentication_method is \"impersonation\"."
  value       = var.authentication_method == "impersonation" ? local.service_account_email : ""
}

output "default_compute_manager_permissions" {
  value = [
    "container.clusters.get",
    "container.clusters.update",
    "container.certificateSigningRequests.approve",
    "compute.instances.get",
    "compute.instances.list",
    "compute.instances.create",
    "compute.instances.start",
    "compute.instances.stop",
    "compute.instances.delete",
    "compute.instances.setLabels",
    "compute.instances.setServiceAccount",
    "compute.instances.setMetadata",
    "compute.instances.setTags",
    "compute.instanceGroupManagers.get",
    "compute.instanceGroupManagers.update",
    "compute.instanceGroups.get",
    "compute.networks.use",
    "compute.networks.useExternalIp",
    "compute.subnetworks.get",
    "compute.subnetworks.use",
    "compute.subnetworks.useExternalIp",
    "compute.addresses.use",
    "compute.disks.use",
    "compute.disks.create",
    "compute.disks.setLabels",
    "compute.images.get",
    "compute.images.useReadOnly",
    "compute.instanceTemplates.get",
    "compute.instanceTemplates.list",
    "compute.instanceTemplates.create",
    "compute.instanceTemplates.delete",
    "compute.regionOperations.get",
    "compute.zoneOperations.get",
    "compute.zones.list",
    "compute.zones.get",
    "serviceusage.services.list",
    "resourcemanager.projects.getIamPolicy",
    "compute.targetPools.get",
    "compute.targetPools.addInstance",
    "compute.targetPools.removeInstance",
    "compute.instances.use",
  ]
}

output "default_castai_role_permissions" {
  value = [
    "container.clusters.get",
    "container.clusters.update",
    "container.certificateSigningRequests.approve",
    "compute.instances.get",
    "compute.instances.list",
    "compute.instances.create",
    "compute.instances.start",
    "compute.instances.stop",
    "compute.instances.delete",
    "compute.instances.setLabels",
    "compute.instances.setServiceAccount",
    "compute.instances.setMetadata",
    "compute.instances.setTags",
    "compute.instanceGroupManagers.get",
    "compute.instanceGroupManagers.update",
    "compute.instanceGroups.get",
    "compute.networks.use",
    "compute.networks.useExternalIp",
    "compute.subnetworks.get",
    "compute.subnetworks.use",
    "compute.subnetworks.useExternalIp",
    "compute.addresses.use",
    "compute.disks.use",
    "compute.disks.create",
    "compute.disks.setLabels",
    "compute.images.get",
    "compute.images.useReadOnly",
    "compute.instanceTemplates.get",
    "compute.instanceTemplates.list",
    "compute.instanceTemplates.create",
    "compute.instanceTemplates.delete",
    "compute.regionOperations.get",
    "compute.zoneOperations.get",
    "compute.zones.list",
    "compute.zones.get",
    "serviceusage.services.list",
    "resourcemanager.projects.getIamPolicy",
    "compute.targetPools.get",
    "compute.targetPools.addInstance",
    "compute.targetPools.removeInstance",
    "compute.instances.use",
  ]
}
