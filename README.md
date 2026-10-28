<a href="https://cast.ai">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset=".github/full-logo-white.svg">
    <source media="(prefers-color-scheme: light)" srcset=".github/full-logo-black.svg">
    <img src=".github/full-logo-black.svg" alt="Cast AI logo" title="Cast AI" align="right" height="50">
  </picture>
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

Using this module is not mandatory. It provides a default set of GCP IAM resources for CAST AI and can also be used as a base for custom configurations - e.g. when different naming, roles or permissions are required.

## Impersonation

Set `authentication_method = "impersonation"` to onboard via GKE service account impersonation instead of a service account JSON private key. The module then grants the CAST AI delegate service account `roles/iam.serviceAccountTokenCreator` on the created service account and exposes the values for the `castai_gke_cluster` impersonation arguments:

```hcl
module "castai_gke_iam" {
  source = "castai/gke-iam/castai"

  project_id            = var.project_id
  gke_cluster_name      = var.cluster_name
  authentication_method = "impersonation"
}

resource "castai_gke_cluster" "castai_cluster" {
  # ...

  target_service_account_email = module.castai_gke_iam.target_service_account_email
  castai_service_account_email = module.castai_gke_iam.castai_service_account_email
}
```

**Note:** when `create_service_account = false`, the module assumes an existing service account named `castai-gke-tf-<sha1 of gke_cluster_name>@<project_id>.iam.gserviceaccount.com` and applies the `roles/iam.serviceAccountTokenCreator` binding to it. That service account is not managed by this module in that case.

## Impersonation preparation in 0.6.x

To improve security, a future version of this module will change the default authentication method from `service_account_key` to `impersonation`.

As this step would cause the existing service account key to be deleted, a failed apply could leave the cluster disconnected. To reduce this risk, a preparation step is added in version 0.6.x.

The step pre-provisions the resources required for impersonation authentication while the module still defaults to `service_account_key`. On upgrade, one additional resource is created: the `roles/iam.serviceAccountTokenCreator` binding that lets the CAST AI service account impersonate the target service account (the `castai_impersonation_service_account` data source is read as well). They are not used for authentication while `authentication_method` is `service_account_key` - the cluster keeps onboarding with the existing service account key - but they allow a later switch to `impersonation` without creating anything at cutover time. The `target_service_account_email` and `castai_service_account_email` outputs are populated during preparation as well, so the cluster module can be switched to impersonation at any time.

Pre-provisioning is controlled with the `authentication_method_migration` variable:
* `prepare` (default): create the impersonation resources early. This requires a castai provider version with GKE impersonation support and permission to grant the service account token creator role on the target service account.
* `none`: opt out - no additional resources are created and no additional permissions are required. Behavior remains exactly as-is.

If `authentication_method` is already set to `impersonation`, this preparation step has no effect. You may opt in to this more secure mode today - there is no need to wait for the default to change - by setting `authentication_method = "impersonation"` as shown in the example above.

Switching can happen gradually or in a single apply. First, update the cluster module (`castai/gke-cluster/castai`) to authenticate via impersonation: remove `gke_credentials` and pass the two module outputs instead, as shown in the example above. Then set `authentication_method` to `impersonation` here - the module stops creating the service account key and produces only the resources required for impersonation. Until then, the module keeps managing the key; it is simply no longer used for onboarding.

# Examples

Usage examples are located in [terraform provider repo](https://github.com/castai/terraform-provider-castai/tree/master/examples/gke)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_castai"></a> [castai](#requirement\_castai) | >= 9.14.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 2.49 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_castai"></a> [castai](#provider\_castai) | >= 9.14.0 |
| <a name="provider_google"></a> [google](#provider\_google) | >= 2.49 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
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
| [google_service_account_iam_member.castai_token_creator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_service_account_key.castai_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [castai_gke_user_policies.gke](https://registry.terraform.io/providers/castai/castai/latest/docs/data-sources/gke_user_policies) | data source |
| [castai_impersonation_service_account.gke](https://registry.terraform.io/providers/castai/castai/latest/docs/data-sources/impersonation_service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_authentication_method"></a> [authentication\_method](#input\_authentication\_method) | Authentication method for CAST AI. Use 'service\_account\_key' for a service account with a JSON private key, or 'impersonation' for GKE service account impersonation | `string` | `"service_account_key"` | no |
| <a name="input_authentication_method_migration"></a> [authentication\_method\_migration](#input\_authentication\_method\_migration) | Controls migration to impersonation authentication as more secure default. 'prepare' pre-provisions the impersonation resources - but they remain unused until the authentication method is switched. 'none' disables any migration behavior. This variable is used for incremental migration and will be removed in the future. | `string` | `"prepare"` | no |
| <a name="input_castai_role_permissions"></a> [castai\_role\_permissions](#input\_castai\_role\_permissions) | A set of permissions that will be granted to CAST AI role used by central system | `list(string)` | `[]` | no |
| <a name="input_cloud_proxy_service_account_name"></a> [cloud\_proxy\_service\_account\_name](#input\_cloud\_proxy\_service\_account\_name) | Name of the cloud-proxy Kubernetes Service Account | `string` | `"castai-cloud-proxy"` | no |
| <a name="input_cloud_proxy_service_account_namespace"></a> [cloud\_proxy\_service\_account\_namespace](#input\_cloud\_proxy\_service\_account\_namespace) | Namespace of the cloud-proxy Kubernetes Service Account | `string` | `"castai-agent"` | no |
| <a name="input_compute_manager_permissions"></a> [compute\_manager\_permissions](#input\_compute\_manager\_permissions) | A set of permissions that will be granted to compute manager role | `list(string)` | `[]` | no |
| <a name="input_compute_manager_project_ids"></a> [compute\_manager\_project\_ids](#input\_compute\_manager\_project\_ids) | Projects list for shared sole tenancy nodes | `list(string)` | `[]` | no |
| <a name="input_create_service_account"></a> [create\_service\_account](#input\_create\_service\_account) | Whether a Service Account with private key should be created. When false, an existing service account named castai-gke-tf-<sha1 of gke\_cluster\_name>@<project\_id>.iam.gserviceaccount.com is expected, and IAM bindings (including the impersonation token creator role) are applied to it | `bool` | `true` | no |
| <a name="input_gke_cluster_name"></a> [gke\_cluster\_name](#input\_gke\_cluster\_name) | GKE cluster name for which to create IAM roles | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project id from GCP | `string` | n/a | yes |
| <a name="input_service_accounts_unique_ids"></a> [service\_accounts\_unique\_ids](#input\_service\_accounts\_unique\_ids) | Service Accounts' unique IDs used by node pools in the cluster | `list(string)` | `[]` | no |
| <a name="input_setup_cloud_proxy_workload_identity"></a> [setup\_cloud\_proxy\_workload\_identity](#input\_setup\_cloud\_proxy\_workload\_identity) | Whether the workload identity for castai-cloud-proxy should be setup | `bool` | `false` | no |
| <a name="input_workload_identity_namespace"></a> [workload\_identity\_namespace](#input\_workload\_identity\_namespace) | Override workload identity namespace, default is <project-id>.svc.id.goog | `string` | `""` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_castai_service_account_email"></a> [castai\_service\_account\_email](#output\_castai\_service\_account\_email) | Email of the CAST AI organization service account that performs the impersonation. Empty unless impersonation resources are created: authentication\_method is "impersonation" or authentication\_method\_migration is "prepare". |
| <a name="output_castai_service_account_id"></a> [castai\_service\_account\_id](#output\_castai\_service\_account\_id) | ID of the CAST AI organization service account that performs the impersonation, as returned by the castai\_impersonation\_service\_account data source. Empty unless impersonation resources are created: authentication\_method is "impersonation" or authentication\_method\_migration is "prepare". |
| <a name="output_default_castai_role_permissions"></a> [default\_castai\_role\_permissions](#output\_default\_castai\_role\_permissions) | n/a |
| <a name="output_default_compute_manager_permissions"></a> [default\_compute\_manager\_permissions](#output\_default\_compute\_manager\_permissions) | n/a |
| <a name="output_private_key"></a> [private\_key](#output\_private\_key) | Private key of the created service account. Empty unless create\_service\_account is true and authentication\_method is "service\_account\_key". |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | Email of the service account CAST AI uses to access the cluster. In impersonation mode this is the account CAST AI impersonates. |
| <a name="output_service_account_id"></a> [service\_account\_id](#output\_service\_account\_id) | Account ID of the service account CAST AI uses to access the cluster. Empty when create\_service\_account is false. |
| <a name="output_target_service_account_email"></a> [target\_service\_account\_email](#output\_target\_service\_account\_email) | Email of the service account in the GCP project that CAST AI impersonates. Empty unless impersonation resources are created: authentication\_method is "impersonation" or authentication\_method\_migration is "prepare". |
<!-- END_TF_DOCS -->