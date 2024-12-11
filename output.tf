output "private_key" {
  value     = var.create_service_account ? base64decode(google_service_account_key.castai_key[0].private_key) : ""
  sensitive = true

  depends_on = [
    # Wait for binding and custom role creation
    # so Service Account will have proper permissions level
    google_project_iam_member.project,
    google_project_iam_member.scoped_project,
    google_project_iam_custom_role.castai_role
  ]
}

output "service_account_id" {
  value = var.create_service_account ? google_service_account.castai_service_account[0].account_id : ""
}

output "service_account_email" {
  value = var.create_service_account ? google_service_account.castai_service_account[0].email : ""
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
    "compute.instances.use"]
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
    "compute.instances.use"]
}
