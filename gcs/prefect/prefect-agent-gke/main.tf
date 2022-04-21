resource "google_service_account" "service_account" {
  project      = var.project
  account_id   = var.service_account_name
  display_name = var.description
}

# ----------------------------------------------------------------------------------------------------------------------
# ADD ROLES TO SERVICE ACCOUNT
# Grant the service account the minimum necessary roles and permissions in order to run the GKE cluster
# plus any other roles added through the 'service_account_roles' variable
# ----------------------------------------------------------------------------------------------------------------------
locals {
  all_service_account_roles = concat(var.service_account_roles, [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/container.developer",
    "roles/storage.objectViewer",
    "roles/storage.objectCreator"
  ])
}

resource "google_project_iam_member" "service_account-roles" {
  for_each = toset(local.all_service_account_roles)

  project = var.project
  role    = each.value
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_container_cluster" "primary" {
  name               = "prod-data-cluster-0"
  location           = "us-central1"
  project            = var.project
  min_master_version = var.min_master_version

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.cluster_cidr
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/16"
    services_ipv4_cidr_block = "/16"
  }


}


resource "google_container_node_pool" "default" {
  name           = "general-node-pool"
  location       = "us-central1"
  node_locations = ["us-central1-a"]
  cluster        = google_container_cluster.primary.name
  node_count     = 1

  node_config {
    machine_type = "e2-standard-2"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name     = "general-preemtible-pool"
  location = "us-central1"
  cluster  = google_container_cluster.primary.name

  autoscaling {
    min_node_count = 0
    max_node_count = 30
  }

  node_config {
    preemptible  = true
    machine_type = "e2-highmem-2"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }



}




# resource "google_container_node_pool" "secondary_preemptible_nodes" {
#   name     = "highmem-preemtible-pool"
#   location = "us-central1"
#   cluster  = google_container_cluster.primary.name

#   autoscaling {
#     min_node_count = 1
#     max_node_count = 15
#   }

#   node_config {
#     preemptible  = true
#     machine_type = "e2-highmem-4"

#     # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
#     service_account = google_service_account.service_account.email
#     oauth_scopes = [
#       "https://www.googleapis.com/auth/cloud-platform"
#     ]
#   }



# }
