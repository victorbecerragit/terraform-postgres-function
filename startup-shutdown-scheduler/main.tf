
resource "google_cloud_scheduler_job" "startup" {
  project = var.project_id
  region  = var.region
  name      = "${var.name}-psql-startup"
  schedule  = var.startup_schedule
  time_zone = var.timezone

  pubsub_target {
    topic_name = var.startup_topic
    #topic_name = projects/lynqs-sandbox-ba/topics/InstanceMgmt
    data = base64encode(jsonencode({ "Action": "start"
    }))
  }
}

resource "google_cloud_scheduler_job" "shutdown" {
  project = var.project_id
  region  = var.region
  name      = "${var.name}-psql-shutdown"
  schedule  = var.shutdown_schedule
  time_zone = var.timezone

  pubsub_target {
    topic_name = var.shutdown_topic
    #topic_name = projects/lynqs-sandbox-ba/topics/InstanceMgmt
    data = base64encode(jsonencode({ "Action": "stop"
    }))
  }
}
