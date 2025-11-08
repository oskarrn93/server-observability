terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "4.13.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
  }
}

variable "grafana_token" {
  description = "Grafana api token"
  type        = string
  sensitive   = true
}

provider "grafana" {
  url  = "http://localhost:3200"
  auth = var.grafana_token
}



resource "grafana_data_source" "prometheus" {
  type = "prometheus"
  name = "mimir"
  url  = "http://prometheus:9090"
  json_data_encoded = jsonencode({
    httpMethod        = "POST"
    prometheusType    = "Mimir"
    prometheusVersion = "2.4.0"
  })
}

resource "grafana_data_source" "loki" {
  type              = "loki"
  name              = "loki"
  url               = "http://loki:3100"
  json_data_encoded = jsonencode({})
}


resource "grafana_data_source" "tempo" {
  type = "tempo"
  name = "tempo"
  url  = "http://tempo:4100"
  json_data_encoded = jsonencode({
    streamingEnabled = {
      search  = true
      metrics = true
    }
  })
}



data "local_file" "grafana_dashboard_node_exporter" {
  filename = "${path.module}/grafana/dashboards/node-export-full.json"
}

resource "grafana_dashboard" "node_exporter" {
  config_json = data.local_file.grafana_dashboard_node_exporter.content
}

data "local_file" "grafana_dashboard_docker_containers" {
  filename = "${path.module}/grafana/dashboards/docker-containers.json"
}

resource "grafana_dashboard" "docker_containers" {
  config_json = data.local_file.grafana_dashboard_docker_containers.content
}


