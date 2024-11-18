# For default in dev account
provider "aws" {
  region  = "ap-northeast-1"
  profile = "tf-user@Sandbox"

  default_tags {
    tags = local.base_tags
  }
}

# For Global resources in dev account
provider "aws" {
  alias   = "virginia"
  region  = "ap-northeast-1"
  profile = "tf-user@Sandbox"

  default_tags {
    tags = local.base_tags
  }
}

# provider "aws" {
#   alias   = "route53"
#   region  = "us-east-1"
#   profile = "sample-profile-for-route53"

#   default_tags {
#     tags = local.base_tags
#   }
# }
