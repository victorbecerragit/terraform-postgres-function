variable "name" {
  type        = string
  description = "Name of the schedule"
}

variable "region" {
  type        = string
  default     = "europe-west6"
}

variable "startup_schedule" {
  default     = "0 5 * * *"
  type        = string
  description = "Cron schedule for startup"
}

variable "shutdown_schedule" {
  default     = "0 23 * * *"
  type        = string
  description = "Cron schedule for shutdown"
}

variable "timezone" {
  default     = "Europe/Zurich"
  type        = string
  description = "Timezone for scheduling"
}

variable "startup_topic" {
  type        = string
  description = "PubSub topic where to publish startup messages"
}

variable "shutdown_topic" {
  type        = string
  description = "PubSub topic where to publish shutdown messages"
}

variable "labels" {
  type        = list(string)
  description = "List of key=value labels to match"
  default     = []
}

variable "custom_filter_query" {
  type        = string
  default     = null
  description = "Custom filter for advanced queries"
}

variable "project_id" {
  description = "Project where to create resources"
  type        = string
}

variable "node_pool_id" {
  description = "Node Pool ID to be scaled up/down"
  type        = string
  default     = null
}
