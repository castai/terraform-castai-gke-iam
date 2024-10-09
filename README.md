<a href="https://cast.ai">
    <img src="https://cast.ai/wp-content/themes/cast/img/cast-logo-dark-blue.svg" align="right" height="100" />
</a>

Terraform module for creating GCP IAM resources required to connect GKE with CAST AI.
==================


Website: https://www.cast.ai

Requirements
------------

- [Terraform](https://www.terraform.io/downloads.html) 0.13+

Using the module
------------


```hcl
module "castai_gke_iam" {
  source = "castai/gke-iam/castai"
  
  project_id = var.project_id
  gke_cluster_name = var.cluster_name

}
```

# Examples

Usage examples are located in [terraform provider repo](https://github.com/castai/terraform-provider-castai/tree/master/examples/gke)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_castai"></a> [castai](#requirement\_castai) | >= 5.1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 2.49 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_castai"></a> [castai](#provider\_castai) | >= 5.1.0 |
| <a name="provider_google"></a> [google](#provider\_google) | >= 2.49 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_project_iam_binding.compute_manager_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_project_iam_custom_role.castai_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_custom_role.compute_manager_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_member.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.scoped_project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.scoped_service_account_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.workload_identity_project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.workload_identity_scoped_project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.workload_identity_scoped_service_account_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.castai_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_key.castai_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [castai_gke_user_policies.gke](https://registry.terraform.io/providers/castai/castai/latest/docs/data-sources/gke_user_policies) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_proxy_service_account_name"></a> [cloud\_proxy\_service\_account\_name](#input\_cloud\_proxy\_service\_account\_name) | Name of the cloud-proxy Kubernetes Service Account | `string` | `"castai-cloud-proxy"` | no |
| <a name="input_cloud_proxy_service_account_namespace"></a> [cloud\_proxy\_service\_account\_namespace](#input\_cloud\_proxy\_service\_account\_namespace) | Namespace of the cloud-proxy Kubernetes Service Account | `string` | `"castai-agent"` | no |
| <a name="input_compute_manager_project_ids"></a> [compute\_manager\_project\_ids](#input\_compute\_manager\_project\_ids) | Projects list for shared sole tenancy nodes | `list(string)` | `[]` | no |
| <a name="input_create_service_account"></a> [create\_service\_account](#input\_create\_service\_account) | Whether an Service Account with private key should be created | `bool` | `true` | no |
| <a name="input_gke_cluster_name"></a> [gke\_cluster\_name](#input\_gke\_cluster\_name) | GKE cluster name for which to create IAM roles | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project id from GCP | `string` | n/a | yes |
| <a name="input_service_accounts_unique_ids"></a> [service\_accounts\_unique\_ids](#input\_service\_accounts\_unique\_ids) | Service Accounts' unique IDs used by node pools in the cluster | `list(string)` | `[]` | no |
| <a name="input_setup_cloud_proxy_workload_identity"></a> [setup\_cloud\_proxy\_workload\_identity](#input\_setup\_cloud\_proxy\_workload\_identity) | Whether the workload identity for castai-cloud-proxy should be setup | `bool` | `false` | no |
| <a name="input_workload_identity_namespace"></a> [workload\_identity\_namespace](#input\_workload\_identity\_namespace) | Override workload identity namespaces | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_key"></a> [private\_key](#output\_private\_key) | n/a |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | n/a |
| <a name="output_service_account_id"></a> [service\_account\_id](#output\_service\_account\_id) | n/a |
<!-- END_TF_DOCS -->