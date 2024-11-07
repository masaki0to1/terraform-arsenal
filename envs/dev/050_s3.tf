## S3 ##
# resources origin bucket
module "s3_bucket_resources_origin" {
  source      = "../../modules/s3_bucket"
  bucket_name = "${local.name_prefix}-resources-origin"

  cors_rules = [
    {
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
    }
  ]
}

# admin origin bucket
module "s3_bucket_admin_origin" {
  source      = "../../modules/s3_bucket"
  bucket_name = "${local.name_prefix}-admin-origin"

  cors_rules = [
    {
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
    }
  ]
}

# admin logging bucket
module "s3_bucket_admin_logging" {
  source      = "../../modules/s3_bucket"
  bucket_name = "${local.name_prefix}-admin-logging"
}

module "s3_bucket_policy_resources_origin" {
  source = "../../modules/s3_bucket_policy"

  bucket_id = module.s3_bucket_resources_origin.attrs.bucket_id
  policy_statements = [
    {
      Sid    = "AllowCloudFrontAccess"
      Effect = "Allow"
      Principal = {
        "Service" : "cloudfront.amazonaws.com"
      }
      Action = [
        "s3:GetObject"
      ]
      Resource = [
        "${module.s3_bucket_resources_origin.attrs.arn}/*"
      ]
      Condition = {
        StringEquals = {
          "AWS:SourceArn" : "${module.s3_bucket_cfd_resources.attrs.arn}"
        }
      }
    }
  ]
}

module "s3_bucket_policy_admin_origin" {
  source = "../../modules/s3_bucket_policy"

  bucket_id = module.s3_bucket_admin_origin.attrs.bucket_id
  policy_statements = [
    {
      Sid    = "AllowCloudFrontAccess"
      Effect = "Allow"
      Principal = {
        "Service" : "cloudfront.amazonaws.com"
      }
      Action = [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:ListBucket"
      ]
      Resource = [
        "${module.s3_bucket_admin_origin.attrs.arn}",
        "${module.s3_bucket_admin_origin.attrs.arn}/*"
      ]
      Condition = {
        StringEquals = {
          "AWS:SourceArn" : "${module.landing_page_cfd_admin.attrs.arn}"
        }
      }
    },
    {
      Sid    = "AllowGithubActionsAccess"
      Effect = "Allow"
      Principal = {
        "AWS" : "${module.iam_role_github_actions_oidc.attrs.arn}"
      }
      Action = [
        "s3:ListBucket",
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ]
      Resource = [
        "${module.s3_bucket_admin_origin.attrs.arn}",
        "${module.s3_bucket_admin_origin.attrs.arn}/*"
      ]
      Condition = {}
    }
  ]
}

module "aws_s3_bucket_ownership_controls" {
  source = "../../modules/s3_bucket_ownership_controls"

  bucket_id        = module.s3_bucket_admin_logging.attrs.id
  object_ownership = "BucketOwnerPreferred"
}

module "s3_bucket_acl_admin" {
  source     = "../../modules/s3_bucket_acl"
  depends_on = [module.aws_s3_bucket_ownership_controls]

  bucket_id = module.s3_bucket_admin_logging.attrs.id
  acl       = "private"
}
