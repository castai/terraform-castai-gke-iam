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
  description = "Whether a Service Account with private key should be created. When false, an existing service account named castai-gke-tf-<sha1 of gke_cluster_name>@<project_id>.iam.gserviceaccount.com is expected, and IAM bindings (including the impersonation token creator role) are applied to it"
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

variable "castai_role_permissions" {
  description = "A set of permissions that will be granted to CAST AI role used by central system"
  type        = list(string)
  default     = []
}

variable "compute_manager_permissions" {
  description = "A set of permissions that will be granted to compute manager role"
  type        = list(string)
  default     = []
}

variable "authentication_method" {
  description = "Authentication method for CAST AI. Use 'service_account_key' for a service account with a JSON private key, or 'impersonation' for GKE service account impersonation"
  type        = string
  default     = "service_account_key"

  validation {
    condition     = contains(["service_account_key", "impersonation"], var.authentication_method)
    error_message = "authentication_method must be either 'service_account_key' or 'impersonation'"
  }
}
