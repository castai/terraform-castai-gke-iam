variable "project_id" {
  type        = string
  description = "The project id from GCP"
}

variable "gke_cluster_name" {
  type        = string
  description = "GKE cluster name for which to create IAM roles"
}

variable "service_accounts_unique_ids" {
  type        = list(string)
  description = "Service Accounts' unique IDs used by node pools in the cluster"
  default     = []
}

variable "compute_manager_project_ids" {
  type        = list(string)
  description = "st project id"
}
