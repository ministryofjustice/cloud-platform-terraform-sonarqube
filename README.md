# cloud-platform-terraform-sonarqube

<a href="https://github.com/ministryofjustice/cloud-platform-terraform-sonarqube/releases">
  <img src="https://img.shields.io/github/release/ministryofjustice/cloud-platform-terraform-sonarqube/all.svg" alt="Releases" />
</a>

Terraform module that deploy cloud-platform sonarqube. [SonarQube](https://www.sonarqube.org/) is an open sourced code quality scanning tool.

## Usage

```hcl
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
```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cluster_domain_name           | The cluster domain - used by sonarqube               | string | | yes |
| oidc_components_client_id     | OIDC ClientID used to authenticate to sonarqube)     | string | | yes |
| oidc_components_client_secret | OIDC ClientSecret used to authenticate to sonarqube) | string | | yes |
| oidc_issuer_url               | Issuer URL used to authenticate to sonarqube)        | string | | yes |
| vpc_id                        | The VPC ID used to create sonarqube PostgreSQL       | string | | yes |
| internal_subnets              | The subnets used to create sonarqube PostgreSQL      | string | | yes |
| internal_subnets_ids          | The subnets used to create sonarqube PostgreSQL        | string | | yes |

## Reading Material

Click [here](https://github.com/Oteemo/charts/tree/master/charts/sonarqube) and [here](https://www.sonarqube.org/) for the sonarqube documentation.