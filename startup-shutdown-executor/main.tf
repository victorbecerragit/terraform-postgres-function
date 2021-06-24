# https://cloud.google.com/scheduler/docs/start-and-stop-compute-engine-instances-on-a-schedule#set_up_the_functions_with
# Service account and permissions

resource "google_service_account" "psql-executor" {
  project      = var.project_id
  account_id   = "${var.name_prefix}-psql-start-stop"
  display_name = "${var.name_prefix} startup-shutdown"
}

resource "google_project_iam_custom_role" "psql-executor" {
  project = var.project_id
  permissions = [
    "cloudsql.instances.get",
    "cloudsql.instances.update",
    "cloudsql.instances.restart"
  ]
  role_id = replace("${var.name_prefix}-start-stop", "-", "_")
  title   = "Permissions to start-stop instances"
}

resource "google_project_iam_member" "psql-executor" {
  project = var.project_id
  member = "serviceAccount:${google_service_account.psql-executor.email}"
  role   = google_project_iam_custom_role.psql-executor.id
}

# PubSub topic
resource "google_pubsub_topic" "star-stop-psql" {
  project = var.project_id
  name    = "InstanceMgmt"
}

# Cloud Functions

resource "google_cloudfunctions_function" "star-stop-psql" {
  project = var.project_id
  name    = "${var.name_prefix}-start-stop-cloud-psql-instance"
  runtime = "go113"

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = "projects/${var.project_id}/topics/InstanceMgmt"
  }

  service_account_email = google_service_account.psql-executor.email
  #service_account_email = "lynqs-sandbox-start-stop@lynqs-sandbox-ba.iam.gserviceaccount.com"

  region = var.cloudfunction_region

  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.startup.name

  entry_point = "ProcessPubSub"

  environment_variables = {
    CLOUD_PROJECT_ID   = var.project_id
    PSQL_INSTANCE_NAME = var.psql_instance_name
  }
}

# Function code

data "archive_file" "startup" {
  type        = "zip"
  output_path = "${path.module}/startup.zip"
  source_dir  = "${path.module}/startup"
}

resource "google_storage_bucket" "bucket" {
  project  = var.project_id
  name     = "${var.name_prefix}-psql-startup-shutdown-scripts"
  location = var.bucket_region
}

resource "google_storage_bucket_object" "startup" {
  name   = "${data.archive_file.startup.output_md5}-startup.zip"
  bucket = google_storage_bucket.bucket.name
  source = "${path.module}/startup.zip"
}

resource "google_storage_bucket_iam_member" "executor" {
  bucket = google_storage_bucket.bucket.name
  #member = "serviceAccount:lynqs-sandbox-start-stop@lynqs-sandbox-ba.iam.gserviceaccount.com"
  member = "serviceAccount:${google_service_account.psql-executor.email}"
  role = "roles/storage.objectViewer"
}
