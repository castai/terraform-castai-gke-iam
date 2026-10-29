mock_provider "google" {
  mock_resource "google_service_account" {
    defaults = {
      email  = "castai-gke-tf-abc12345@test-project.iam.gserviceaccount.com"
      member = "serviceAccount:castai-gke-tf-abc12345@test-project.iam.gserviceaccount.com"
      name   = "projects/test-project/serviceAccounts/castai-gke-tf-abc12345@test-project.iam.gserviceaccount.com"
    }
  }

  mock_resource "google_service_account_key" {
    defaults = {
      private_key = "dGVzdC1wcml2YXRlLWtleQ=="
    }
  }

  mock_resource "google_project_iam_custom_role" {
    defaults = {
      id = "projects/test-project/roles/castai.gkeAccess.abc12345.tf"
    }
  }

  mock_resource "google_project_iam_member" {
    defaults = {
      etag = "BwWXq3zZQx0="
    }
  }

  mock_resource "google_service_account_iam_member" {
    defaults = {
      etag = "BwWXq3zZQx1="
    }
  }
}

mock_provider "castai" {
  mock_data "castai_gke_user_policies" {
    defaults = {
      policy = [
        "container.clusters.get",
        "container.clusters.update",
        "container.certificateSigningRequests.approve",
      ]
    }
  }

  mock_data "castai_impersonation_service_account" {
    defaults = {
      id    = "castai-gke-impersonation-id"
      email = "castai-gke-impersonator@castai-organization.iam.gserviceaccount.com"
    }
  }
}

variables {
  project_id       = "test-project"
  gke_cluster_name = "test-cluster"

  authentication_method = "impersonation"
}

run "verify_impersonation_resources_created" {
  command = plan

  assert {
    condition     = length([for r in google_service_account_iam_member.castai_token_creator : r]) == 1
    error_message = "Token creator binding should be created for impersonation auth"
  }

  assert {
    condition     = length([for r in data.castai_impersonation_service_account.gke : r]) == 1
    error_message = "CAST AI impersonation service account data source should be queried"
  }
}

run "verify_service_account_key_not_created" {
  command = plan

  assert {
    condition     = length([for r in google_service_account_key.castai_key : r]) == 0
    error_message = "Service account key should NOT be created for impersonation auth"
  }

  assert {
    condition     = length([for r in google_service_account.castai_service_account : r]) == 1
    error_message = "Service account should still be created as the impersonation target"
  }
}

run "verify_token_creator_configuration" {
  command = plan

  assert {
    condition     = google_service_account_iam_member.castai_token_creator[0].role == "roles/iam.serviceAccountTokenCreator"
    error_message = "Token creator binding should grant the serviceAccountTokenCreator role"
  }

  assert {
    condition     = google_service_account_iam_member.castai_token_creator[0].member == "serviceAccount:castai-gke-impersonator@castai-organization.iam.gserviceaccount.com"
    error_message = "Token creator binding should grant the role to the CAST AI impersonation service account"
  }

  assert {
    condition     = google_service_account_iam_member.castai_token_creator[0].service_account_id == "projects/test-project/serviceAccounts/castai-gke-tf-abc12345@test-project.iam.gserviceaccount.com"
    error_message = "Token creator binding should target the module-managed service account"
  }
}

run "verify_impersonation_outputs" {
  command = plan

  assert {
    condition     = output.target_service_account_email == "castai-gke-tf-${substr(sha1("test-cluster"), 0, 8)}@test-project.iam.gserviceaccount.com"
    error_message = "target_service_account_email output should expose the impersonated service account"
  }

  assert {
    condition     = output.castai_service_account_email == "castai-gke-impersonator@castai-organization.iam.gserviceaccount.com"
    error_message = "castai_service_account_email output should expose the CAST AI impersonation service account"
  }

  assert {
    condition     = output.private_key == ""
    error_message = "private_key output should be empty for impersonation auth"
  }
}
