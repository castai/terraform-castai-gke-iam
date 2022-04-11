variable "project_id" {
  type        = string
  description = "The project id from GCP"
}

variable "gke_cluster_name" {
  type = string
  description = "GKE cluster name for which to create IAM roles"
}

