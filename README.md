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
| <a name="requirement_castai"></a> [castai](#requirement\_castai) | >= 0.16.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 2.49 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_castai"></a> [castai](#provider\_castai) | >= 0.16.0 |
| <a name="provider_google"></a> [google](#provider\_google) | >= 2.49 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_project_iam_binding.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_project_iam_custom_role.castai_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_service_account.castai_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_key.castai_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [castai_gke_user_policies.gke](https://registry.terraform.io/providers/castai/castai/latest/docs/data-sources/gke_user_policies) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gke_cluster_name"></a> [gke\_cluster\_name](#input\_gke\_cluster\_name) | GKE cluster name for which create IAM roles | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project id from GCP | `string` | n/a | yes |

## Outputs

| Name                                                                                             | Description                                          |
|--------------------------------------------------------------------------------------------------|------------------------------------------------------|
| <a name="output_private_key"></a> [private\_key](#output\_private\_key)                          | Contains a CAST AI token (sensitive data)            |
| <a name="service_account_id"></a> [service\_account\_id](#output\_service\_account\_id)          | Contains service account ID created by the module    |
| <a name="service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | Contains service account email created by the module |
<!-- END_TF_DOCS -->