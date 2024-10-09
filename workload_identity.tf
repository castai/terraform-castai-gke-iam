locals {
  workload_identity_namespace = var.workload_identity_namespace != "" ? var.workload_identity_namespace : "${var.project_id}.svc.id.goog"
  workload_identity_sa        = "serviceAccount:${local.workload_identity_namespace}[${var.cloud_proxy_service_account_namespace}/${var.cloud_proxy_service_account_name}]"
}

resource "google_project_iam_member" "workload_identity_project" {
  for_each = (
    var.setup_cloud_proxy_workload_identity && length(var.service_accounts_unique_ids) == 0 ?
    { for permission in local.default_permissions : permission => permission } :
    {}
  )

  project = var.project_id
  role    = each.key
  member  = local.workload_identity_sa
}

resource "google_project_iam_member" "workload_identity_scoped_project" {
  for_each = (
    var.setup_cloud_proxy_workload_identity && length(var.service_accounts_unique_ids) > 0 ?
    { for permission in local.scoped_permissions : permission => permission } :
    {}
  )
  project = var.project_id
  role    = each.key
  member  = local.workload_identity_sa
}

resource "google_project_iam_member" "workload_identity_scoped_service_account_user" {
  count   = var.setup_cloud_proxy_workload_identity && length(var.service_accounts_unique_ids) > 0 ? 1 : 0
  project = var.project_id

  role   = "roles/iam.serviceAccountUser"
  member = local.workload_identity_sa

  condition {
    title       = "iam_condition"
    description = "IAM condition with limited scope"
    expression  = local.condition_expression
  }
}

