## ECR ##
module "ecr_repo" {
  source        = "../../modules/ecr"
  ecr_repo_name = "${local.name_prefix}-repo"
}
