# For default in stg account
provider "aws" {
  region  = "ap-northeast-1"
  profile = "tf-user@Sandbox"

  default_tags {
    tags = local.base_tags
  }
}

# For Global resources in stg account
provider "aws" {
  alias   = "virginia"
  region  = "ap-northeast-1"
  profile = "tf-user@Sandbox"

  default_tags {
    tags = local.base_tags
  }
}
