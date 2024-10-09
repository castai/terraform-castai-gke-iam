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
  description = "Projects list for shared sole tenancy nodes"
  default     = []
}

variable "create_service_account" {
  type        = bool
  description = "Whether an Service Account with private key should be created"
  default     = true
}

variable "setup_cloud_proxy_workload_identity" {
  type        = bool
  description = "Whether the workload identity for castai-cloud-proxy should be setup"
  default     = false
}

variable "workload_identity_namespace" {
  type        = string
  description = "Override workload identity namespace, default is <project-id>.svc.id.goog"
  default     = ""
}

variable "cloud_proxy_service_account_namespace" {
  type        = string
  description = "Namespace of the cloud-proxy Kubernetes Service Account"
  default     = "castai-agent"
}


variable "cloud_proxy_service_account_name" {
  type        = string
  description = "Name of the cloud-proxy Kubernetes Service Account"
  default     = "castai-cloud-proxy"
}
