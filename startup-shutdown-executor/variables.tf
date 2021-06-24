variable "name_prefix" {
  description = "Common name for the components, like your-env-dev"
  type        = string
}

variable "project_id" {
  description = "Project where to create resources"
  type        = string
}

variable "psql_instance_name" {
  description = "Psql instance name"
  type        = string
  default     = "your_sql_instance_name"
} 

variable "bucket_region" {
  description = "Region where to create bucket"
  default     = "your_region"
  type        = string
}

variable "cloudfunction_region" {
  description = "Region where to create cloud functions, locations available https://cloud.google.com/functions/docs/locations"
  default     = "europe-west1"
  type        = string
}
