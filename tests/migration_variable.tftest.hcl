# Tests the authentication_method_migration variable introduced in 0.6.x:
#   prepare (default) - pre-provision impersonation resources while
#                       authentication_method is service_account_key
#   none              - opt out of any migration behavior
#
# The apply runs at the end exercise the prep lifecycle:
# prep -> un-prep with none (removes only the pre-provisioned resources).

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

# Defaults: service_account_key auth + prepare migration.
# Impersonation resources are pre-provisioned but unused: the module keeps
# authenticating with the service account key and the impersonation outputs
# stay empty until the authentication method is switched.
run "verify_defaults_pre_provision_impersonation" {
  command = plan

  assert {
    condition     = var.authentication_method == "service_account_key" && var.authentication_method_migration == "prepare"
    error_message = "Defaults should be service_account_key auth with prepare migration"
  }

  assert {
    condition     = length([for r in google_service_account.castai_service_account : r]) == 1
    error_message = "Service account should be created for service_account_key auth"
  }

  assert {
    condition     = length([for r in google_service_account_key.castai_key : r]) == 1
    error_message = "Service account key should be created for service_account_key auth"
  }

  assert {
    condition     = length([for r in google_service_account_iam_member.castai_token_creator : r]) == 1
    error_message = "Token creator binding should be pre-provisioned by prepare"
  }

  assert {
    condition     = length([for r in data.castai_impersonation_service_account.gke : r]) == 1
    error_message = "CAST AI impersonation service account should be read by prepare"
  }

  assert {
    condition     = output.private_key != ""
    error_message = "Module should still authenticate with the service account key under prepare"
  }

  assert {
    condition     = output.target_service_account_email == ""
    error_message = "Impersonation outputs should stay empty while authenticating with the key"
  }
}

# Opt-out: none keeps the previous behavior exactly - no impersonation
# resources, no data source reads, no additional permissions required.
run "verify_none_opts_out_of_prep" {
  command = plan

  variables {
    authentication_method_migration = "none"
  }

  assert {
    condition     = length([for r in google_service_account.castai_service_account : r]) == 1
    error_message = "Service account should still be created with none"
  }

  assert {
    condition     = length([for r in google_service_account_key.castai_key : r]) == 1
    error_message = "Service account key should still be created with none"
  }

  assert {
    condition     = length([for r in google_service_account_iam_member.castai_token_creator : r]) == 0
    error_message = "Token creator binding should NOT be created with none"
  }

  assert {
    condition     = length([for r in data.castai_impersonation_service_account.gke : r]) == 0
    error_message = "CAST AI impersonation service account should NOT be read with none"
  }
}

# prepare has no additional effect once on impersonation.
run "verify_prepare_is_noop_for_impersonation" {
  command = plan

  variables {
    authentication_method = "impersonation"
  }

  assert {
    condition     = length([for r in google_service_account_key.castai_key : r]) == 0
    error_message = "Service account key should NOT be created for impersonation + prepare"
  }

  assert {
    condition     = length([for r in google_service_account_iam_member.castai_token_creator : r]) == 1
    error_message = "Token creator binding should exist for impersonation + prepare"
  }
}

# none + impersonation preserves the pre-migration-variable behavior.
run "verify_none_with_impersonation" {
  command = plan

  variables {
    authentication_method           = "impersonation"
    authentication_method_migration = "none"
  }

  assert {
    condition     = length([for r in google_service_account_key.castai_key : r]) == 0
    error_message = "Service account key should NOT be created for impersonation + none"
  }

  assert {
    condition     = length([for r in google_service_account_iam_member.castai_token_creator : r]) == 1
    error_message = "Token creator binding should exist for impersonation + none"
  }
}

# --- Prep lifecycle (apply runs share state) ---

# Step 1: apply the defaults (service_account_key + prepare): both auth resource
# sets exist; authentication is still on the service account key.
run "apply_defaults_with_prep" {
  command = apply

  assert {
    condition     = length([for r in google_service_account_key.castai_key : r]) == 1
    error_message = "Service account key should exist after prep apply"
  }

  assert {
    condition     = length([for r in google_service_account_iam_member.castai_token_creator : r]) == 1
    error_message = "Token creator binding should exist after prep apply"
  }
}

# Step 2: opting out later must only remove the pre-provisioned impersonation
# resources; the service_account_key setup is untouched.
run "plan_unprep_with_none" {
  command = plan

  variables {
    authentication_method_migration = "none"
  }

  assert {
    condition     = length([for r in google_service_account_iam_member.castai_token_creator : r]) == 0
    error_message = "Token creator binding should be removed by the un-prep plan"
  }

  assert {
    condition     = length([for r in data.castai_impersonation_service_account.gke : r]) == 0
    error_message = "CAST AI impersonation service account should not be read by the un-prep plan"
  }

  assert {
    condition     = length([for r in google_service_account.castai_service_account : r]) == 1
    error_message = "Service account should be untouched by the un-prep plan"
  }

  assert {
    condition     = length([for r in google_service_account_key.castai_key : r]) == 1
    error_message = "Service account key should be untouched by the un-prep plan"
  }
}

# Step 3: apply the un-prep. Destroy-only for the impersonation resources.
run "apply_unprep_with_none" {
  command = apply

  variables {
    authentication_method_migration = "none"
  }

  assert {
    condition     = length([for r in google_service_account_iam_member.castai_token_creator : r]) == 0
    error_message = "Token creator binding should be removed from state by the un-prep apply"
  }

  assert {
    condition     = length([for r in data.castai_impersonation_service_account.gke : r]) == 0
    error_message = "CAST AI impersonation service account should be removed from state by the un-prep apply"
  }

  assert {
    condition     = length([for r in google_service_account.castai_service_account : r]) == 1
    error_message = "Service account should remain after the un-prep apply"
  }

  assert {
    condition     = length([for r in google_service_account_key.castai_key : r]) == 1
    error_message = "Service account key should remain after the un-prep apply"
  }
}
