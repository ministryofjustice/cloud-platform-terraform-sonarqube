
######################
# Namespace creation #
######################
resource "kubernetes_namespace" "sonarqube" {
  count = var.enable_sonarqube ? 1 : 0

  metadata {
    name = "sonarqube"

    labels = {
      "component" = "sonarqube"
    }

    annotations = {
      "cloud-platform.justice.gov.uk/application"   = "sonarqube"
      "cloud-platform.justice.gov.uk/business-unit" = "cloud-platform"
      "cloud-platform.justice.gov.uk/owner"         = "Cloud Platform: platforms@digital.justice.gov.uk"
      "cloud-platform.justice.gov.uk/source-code"   = "https://github.com/ministryofjustice/cloud-platform-infrastructure"
    }
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

#######################
# Create RDS database #
#######################

resource "aws_security_group" "sonarqube" {
  count = var.enable_sonarqube ? 1 : 0

  name        = "${terraform.workspace}-sonarqube"
  description = "Allow all inbound traffic from the VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.internal_subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${terraform.workspace}-sonarqube"
  }
}

resource "aws_db_subnet_group" "sonarqube" {
  count = var.enable_sonarqube ? 1 : 0

  name        = "${terraform.workspace}-sonarqube"
  description = "Internal subnet groups"
  subnet_ids  = var.internal_subnets_ids
}

resource "random_password" "db_password" {
  count = var.enable_sonarqube ? 1 : 0

  length  = 32
  special = false
}

resource "aws_db_instance" "sonarqube" {
  count = var.enable_sonarqube ? 1 : 0

  depends_on             = [aws_security_group.sonarqube]
  identifier             = "${terraform.workspace}-sonarqube"
  allocated_storage      = var.rds_storage
  engine                 = "postgres"
  engine_version         = var.rds_postgresql_version
  instance_class         = var.rds_instance_class
  name                   = "sonarqube"
  username               = "sonarqube"
  password               = random_password.db_password[count.index].result
  vpc_security_group_ids = [aws_security_group.sonarqube[count.index].id]
  db_subnet_group_name   = aws_db_subnet_group.sonarqube[count.index].id
  skip_final_snapshot    = true
}

##################
# sonarqube helm #
##################

data "helm_repository" "oteemocharts" {

  name = "oteemocharts"
  url  = "https://oteemo.github.io/charts"
}

resource "helm_release" "sonar_qube" {
  count = var.enable_sonarqube ? 1 : 0

  name       = "sonarqube"
  repository = data.helm_repository.oteemocharts.metadata[0].name
  chart      = "sonarqube"
  namespace  = kubernetes_namespace.sonarqube[count.index].id
  version    = var.sonarqube_chart_version

  values = [templatefile("${path.module}/templates/sonarqube.yaml", {

    sonarqube_hostname  = local.hostname
    storage_class       = "gp2"
    sonarqube_image_tag = var.sonarqube_image_tag
    issuer_url          = var.oidc_issuer_url
    client_id           = var.oidc_components_client_id
    postgresql_name     = aws_db_instance.sonarqube[count.index].name
    postgresql_user     = aws_db_instance.sonarqube[count.index].username
    postgresql_host     = aws_db_instance.sonarqube[count.index].address
    oidc_plugin_version = var.sonar_auth_oidc_plugin_version
  })]

  # Depends on Helm being installed
  depends_on = [
    kubernetes_secret.auth0_credentials,
    kubernetes_secret.postgresql_credentials,
  ]

  lifecycle {
    ignore_changes = [keyring]
  }
}

######################
# Kubernetes Secrets #
######################

resource "random_password" "basic_auth_password" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "auth0_credentials" {
  count = var.enable_sonarqube ? 1 : 0

  metadata {
    name      = "auth0-credentials"
    namespace = kubernetes_namespace.sonarqube[count.index].id
  }

  data = {
    "secret.properties" = "sonar.auth.oidc.clientSecret.secured=${var.oidc_components_client_secret}"
  }
}

resource "kubernetes_secret" "postgresql_credentials" {
  count = var.enable_sonarqube ? 1 : 0

  metadata {
    name      = "postgresql-credentials"
    namespace = kubernetes_namespace.sonarqube[count.index].id
  }

  data = {
    postgresql-db-name  = aws_db_instance.sonarqube[count.index].name
    postgresql-user     = aws_db_instance.sonarqube[count.index].username
    postgresql-password = aws_db_instance.sonarqube[count.index].password
  }
}

resource "kubernetes_secret" "basic_auth_credentials" {
  count = var.enable_sonarqube ? 1 : 0

  metadata {
    name      = "basic-auth-credentials"
    namespace = kubernetes_namespace.sonarqube[count.index].id
  }

  data = {
    basic-auth-username     = "admin"
    basic-auth-password     = random_password.basic_auth_password.result
  }
}

####################################
# Update default Admin Credentials #
####################################

resource "null_resource" "change_password" {
  count = var.enable_sonarqube ? 1 : 0

  depends_on    = [helm_release.sonar_qube]
  provisioner "local-exec" {
    command     = <<EOT
      curl -u admin:admin \
      -X POST "https://${local.hostname}/api/users/change_password?login=admin&previousPassword=admin&password=${local.basic_auth_password}"
EOT
  }
}

##########
# Locals #
##########

locals {
  live_workspace = "manager"
  live_domain    = "cloud-platform.service.justice.gov.uk"
  basic_auth_password = random_password.basic_auth_password.result
  hostname = terraform.workspace == local.live_workspace ? format("%s.%s", "sonarqube", local.live_domain) : format(
    "%s.%s",
    "sonarqube.apps",
    var.cluster_domain_name,
  )
}
