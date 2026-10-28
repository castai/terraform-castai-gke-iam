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
}

run "invalid_authentication_method" {
  command = plan

  variables {
    authentication_method = "invalid_method"
  }

  expect_failures = [
    var.authentication_method,
  ]
}

run "valid_service_account_key_authentication_method" {
  command = plan

  variables {
    authentication_method = "service_account_key"
  }

  assert {
    condition     = var.authentication_method == "service_account_key"
    error_message = "Should accept 'service_account_key' as valid authentication_method"
  }
}

run "valid_impersonation_authentication_method" {
  command = plan

  variables {
    authentication_method = "impersonation"
  }

  assert {
    condition     = var.authentication_method == "impersonation"
    error_message = "Should accept 'impersonation' as valid authentication_method"
  }
}

run "invalid_authentication_method_migration" {
  command = plan

  variables {
    authentication_method_migration = "invalid_value"
  }

  expect_failures = [
    var.authentication_method_migration,
  ]
}

run "default_migration_is_prepare" {
  command = plan

  assert {
    condition     = var.authentication_method_migration == "prepare"
    error_message = "Default migration should be 'prepare'"
  }
}

run "valid_migration_value_none" {
  command = plan

  variables {
    authentication_method_migration = "none"
  }

  assert {
    condition     = contains(["prepare", "none"], var.authentication_method_migration)
    error_message = "Should accept 'none' as valid migration"
  }
}
