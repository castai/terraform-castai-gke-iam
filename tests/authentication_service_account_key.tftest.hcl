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

  authentication_method_migration = "none"
}

run "verify_default_authentication_method" {
  command = plan

  assert {
    condition     = var.authentication_method == "service_account_key"
    error_message = "Default authentication_method should be 'service_account_key'"
  }
}

run "verify_service_account_resources_created" {
  command = plan

  assert {
    condition     = length([for r in google_service_account.castai_service_account : r]) == 1
    error_message = "Service account should be created for service_account_key auth"
  }

  assert {
    condition     = length([for r in google_service_account_key.castai_key : r]) == 1
    error_message = "Service account key should be created for service_account_key auth"
  }

  assert {
    condition     = google_project_iam_custom_role.castai_role.role_id == "castai.gkeAccess.${substr(sha1("test-cluster"), 0, 8)}.tf"
    error_message = "CAST AI custom role should be created for service_account_key auth"
  }
}

run "verify_impersonation_resources_not_created" {
  command = plan

  assert {
    condition     = length([for r in google_service_account_iam_member.castai_token_creator : r]) == 0
    error_message = "Token creator binding should NOT be created for service_account_key auth with migration none"
  }

  assert {
    condition     = length([for r in data.castai_impersonation_service_account.gke : r]) == 0
    error_message = "CAST AI impersonation service account should NOT be queried for service_account_key auth with migration none"
  }
}

run "verify_private_key_output" {
  command = plan

  assert {
    condition     = base64decode(google_service_account_key.castai_key[0].private_key) == "test-private-key"
    error_message = "Private key output should expose the created service account key"
  }
}
