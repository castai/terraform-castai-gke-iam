mock_provider "google" {
  mock_resource "google_service_account" {
    defaults = {
      email  = "mock-sa@test-project.iam.gserviceaccount.com"
      member = "serviceAccount:mock-sa@test-project.iam.gserviceaccount.com"
      name   = "projects/test-project/serviceAccounts/mock-sa@test-project.iam.gserviceaccount.com"
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
}

run "custom_service_account_id_creates_service_account_with_custom_name" {
  command = plan

  variables {
    service_account_id = "my-custom-sa"
  }

  assert {
    condition     = google_service_account.castai_service_account[0].account_id == "my-custom-sa"
    error_message = "Service account should be created with the custom account ID"
  }

  assert {
    condition     = length([for r in google_service_account_key.castai_key : r]) == 1
    error_message = "Service account key should be created when create_service_account is true and authentication_method is 'service_account_key'"
  }

  assert {
    condition     = output.target_service_account_email == "my-custom-sa@test-project.iam.gserviceaccount.com"
    error_message = "target_service_account_email output should use the custom service account email"
  }
}

run "custom_service_account_id_used_for_existing_service_account" {
  command = plan

  variables {
    service_account_id          = "my-custom-sa"
    create_service_account      = false
    authentication_method       = "impersonation"
    compute_manager_project_ids = ["shared-project"]
  }

  assert {
    condition     = length([for r in google_service_account.castai_service_account : r]) == 0
    error_message = "Service account should not be created when create_service_account is false"
  }

  assert {
    condition     = length([for r in google_service_account_key.castai_key : r]) == 0
    error_message = "Service account key should not be created when create_service_account is false"
  }

  assert {
    condition     = google_service_account_iam_member.castai_token_creator[0].service_account_id == "projects/test-project/serviceAccounts/my-custom-sa@test-project.iam.gserviceaccount.com"
    error_message = "Token creator binding should target the custom existing service account"
  }

  assert {
    condition     = contains(google_project_iam_binding.compute_manager_binding["shared-project"].members, "serviceAccount:my-custom-sa@test-project.iam.gserviceaccount.com")
    error_message = "Compute manager binding member should use the custom existing service account"
  }

  assert {
    condition     = output.service_account_email == "my-custom-sa@test-project.iam.gserviceaccount.com"
    error_message = "service_account_email output should expose the custom existing service account"
  }

  assert {
    condition     = output.target_service_account_email == "my-custom-sa@test-project.iam.gserviceaccount.com"
    error_message = "target_service_account_email output should expose the custom existing service account"
  }
}

run "default_service_account_id_unchanged" {
  command = plan

  assert {
    condition     = google_service_account.castai_service_account[0].account_id == "castai-gke-tf-${substr(sha1("test-cluster"), 0, 8)}"
    error_message = "Service account should keep the default computed account ID when service_account_id is not set"
  }

  assert {
    condition     = output.target_service_account_email == "castai-gke-tf-${substr(sha1("test-cluster"), 0, 8)}@test-project.iam.gserviceaccount.com"
    error_message = "target_service_account_email output should keep the default computed email when service_account_id is not set"
  }
}
