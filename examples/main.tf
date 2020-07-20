
module "sonarqube" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sonarqube?ref=0.0.1"

  vpc_id                        = data.terraform_remote_state.cluster.outputs.vpc_id
  internal_subnets              = data.terraform_remote_state.cluster.outputs.internal_subnets
  internal_subnets_ids          = data.terraform_remote_state.cluster.outputs.internal_subnets_ids
  cluster_domain_name           = data.terraform_remote_state.cluster.outputs.cluster_domain_name
  oidc_components_client_id     = data.terraform_remote_state.cluster.outputs.oidc_components_client_id
  oidc_components_client_secret = data.terraform_remote_state.cluster.outputs.oidc_components_client_secret
  oidc_issuer_url               = data.terraform_remote_state.cluster.outputs.oidc_issuer_url

  # This is to enable sonarqube, by default it is false for test clusters
  enable_sonarqube = terraform.workspace == local.live_workspace ? true : false
}
