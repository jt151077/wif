/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


resource "google_iam_workload_identity_pool" "github" {
  depends_on = [
    google_project_service.gcp_services
  ]

  project                   = local.project_id
  workload_identity_pool_id = "github-actions"
  display_name              = "GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "github-provider" {
  depends_on = [
    google_project_service.gcp_services
  ]

  project                            = local.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "github-provider"
  description                        = "OIDC identity pool provider for automated test"
  attribute_condition                = "assertion.repository=='jt151077/wif'"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"       = "assertion.aud"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}


resource "google_service_account" "github-wif" {
  depends_on = [
    google_project_service.gcp_services
  ]

  project    = var.project_id
  account_id = "github-wif"
}

resource "google_service_account_iam_binding" "iam-workloadIdentityUser" {
  service_account_id = google_service_account.github-wif.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/projects/50888160022/locations/global/workloadIdentityPools/github-actions/attribute.repository/jt151077/wif"
  ]

  depends_on = [
    google_service_account.github-wif,
    google_iam_workload_identity_pool.github
  ]
}

resource "google_project_iam_member" "github-storageAdmin" {
  depends_on = [
    google_service_account.github-wif
  ]

  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.github-wif.email}"
}

resource "google_project_iam_member" "github-cloudbuildEditor" {
  depends_on = [
    google_service_account.github-wif
  ]

  project = var.project_id
  role    = "roles/cloudbuild.builds.editor"
  member  = "serviceAccount:${google_service_account.github-wif.email}"
}

resource "google_project_iam_member" "github-serviceAccountUser" {
  depends_on = [
    google_service_account.github-wif
  ]

  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.github-wif.email}"
}

resource "google_project_iam_member" "github-runDeveloper" {
  depends_on = [
    google_service_account.github-wif
  ]

  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.github-wif.email}"
}


#
### Service account for the frontend Cloud Run service
#
resource "google_service_account" "frontend_cloudrun_sa" {
  depends_on = [
    google_project_service.gcp_services
  ]

  project    = var.project_id
  account_id = "frontend-cloudrun-sa"
}

#
### Frontend service account access to artifact registry to deploy the container
#
resource "google_project_iam_member" "fe_run_artifactregistry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.frontend_cloudrun_sa.email}"
}

#
### Frontend service account access to write logs
#
resource "google_project_iam_member" "fe_run_logs_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.frontend_cloudrun_sa.email}"
}

#
### Allow unauthorised access to frontend cloud run service (still must be accessed internal or via the Global Load Balancer)
#
resource "google_cloud_run_service_iam_binding" "fe_unauthorised_access" {
  location = var.project_default_region
  project  = var.project_id
  service  = google_cloud_run_service.frontend_run.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}





#
### Service account for the Cloud Build service
#
resource "google_service_account" "cloudbuild_sa" {
  depends_on = [
    google_project_service.gcp_services
  ]

  project    = var.project_id
  account_id = "cloudbuild-sa"
}

resource "google_project_iam_member" "cloudbuild_sa_builder" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

/*

$ terraform import google_service_account.github-wif projects/jeremy-r7znm7yq/serviceAccounts/github-wif
$ terraform import google_iam_workload_identity_pool.github projects/jeremy-r7znm7yq/locations/global/workloadIdentityPools/github-actions-pool

$ terraform import google_iam_workload_identity_pool_provider.github-provider projects/jeremy-r7znm7yq/locations/global/workloadIdentityPools/github-actions-pool/providers/github-provider



#
### Service account for deploying services
#
resource "google_project_iam_member" "github-serviceAccountTokenCreator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.gihub-sa.email}"
}

resource "google_project_iam_member" "github-cloudbuildBuilder" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_service_account.gihub-sa.email}"
}

resource "google_project_iam_member" "github_artifactregistry_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.gihub-sa.email}"
}

resource "google_project_iam_member" "github_logs_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gihub-sa.email}"
}




*/