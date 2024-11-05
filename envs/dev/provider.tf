# For default

provider "aws" {
  alias   = "tokyo"
  region  = "ap-northeast-1"
  profile = "sample-profile"

  default_tags {
    tags = local.base_tags
  }
}

provider "aws" {
  alias   = "virginia"
  region  = "us-east-1"
  profile = "sample-profile"

  default_tags {
    tags = local.base_tags
  }
}

provider "aws" {
  alias   = "route53"
  region  = "us-east-1"
  profile = "sample-profile"

  default_tags {
    tags = local.base_tags
  }
}
