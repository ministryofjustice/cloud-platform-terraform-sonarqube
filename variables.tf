variable "cluster_domain_name" {
  description = "The cluster domain - used by sonarqube to create URLs"
}

variable "oidc_components_client_id" {
  description = "OIDC ClientID used to authenticate to sonarqube"
}

variable "oidc_components_client_secret" {
  description = "OIDC ClientSecret used to authenticate to sonarqube"
}

variable "oidc_issuer_url" {
  description = "Issuer URL used to authenticate to sonarqube"
}

variable "rds_storage" {
  default     = "10"
  description = "RDS storage size in GB"
}

variable "rds_postgresql_version" {
  default     = "10"
  description = "Version of PostgreSQL RDS to use"
}

variable "rds_instance_class" {
  default     = "db.t2.micro"
  description = "RDS instance class"
}

variable "sonarqube_image_tag" {
  default     = "8.2-community"
  description = "The docker image tag to use"
}

variable "sonarqube_chart_version" {
  default     = "6.6.0"
  description = "The Helm chart version"
}

variable "sonar_auth_oidc_plugin_version" {
  default     = "2.0.0"
  description = "sonar auth oid plugin version"
}

variable "vpc_name" {
  default     = ""
  description = "The VPC where deployment is going to happen"
}

variable "cluster_name" {
  default     = ""
  description = "The cluster name where is going to be deployed"
}

variable "vpc_id" {
  default     = ""
  description = "The VPC ID used to create sonarqube PostgreSQL RDS"
}

variable "internal_subnets" {
  default     = ""
  description = "The internal_subnets used to create sonarqube PostgreSQL RDS"
}

variable "internal_subnets_ids" {
  default     = ""
  description = "The internal_subnet id' used to create sonarqube PostgreSQL RDS"
}

variable "enable_sonarqube" {
  description = "Enable wheter to have the sonarqube deployed"
  default     = false
  type        = bool
}
