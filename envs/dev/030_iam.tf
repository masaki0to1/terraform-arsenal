## IAM ##
# scheduler role
module "iam_role_scheduler" {
  source    = "../../modules/iam_role"
  role_name = "${local.name_prefix}-scheduler"

  assume_role_statements = [
    {
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = ["scheduler.amazonaws.com"]
      }
    }
  ]
}

# scheduler policy
module "iam_policy_scheduler" {
  source      = "../../modules/iam_policy"
  policy_name = "${local.name_prefix}-scheduler"
  role_id     = module.iam_role_scheduler.attrs.id

  policy_statements = [
    {
      effect = "Allow"
      actions = [
        "ecs:UpdateService",
        "ec2:StartInstances",
        "ec2:StopInstances",
        "rds:StartDBCluster",
        "rds:StopDBCluster"
      ]
      resources = ["*"]
    }
  ]
}

# ec2 role
module "iam_role_ec2" {
  source    = "../../modules/iam_role"
  role_name = "${local.name_prefix}-ec2"

  assume_role_statements = [
    {
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = ["ec2.amazonaws.com"]
      }
    }
  ]
}

# ec2 policy
module "iam_policy_ec2" {
  source      = "../../modules/iam_policy"
  policy_name = "${local.name_prefix}-ec2"
  role_id     = module.iam_role_ec2.attrs.id

  policy_statements = [
    {
      effect = "Allow"
      actions = [
        "ssm:StartSession",
        "ssm:SendCommand",
        "ssm:TerminateSession",
        "ssm:GetCommandInvocation",
        "ssm:ListCommandInvocations"
      ]
      resources = ["*"]
    }
  ]
}

# ec2 attachment
module "iam_attachment_ec2" {
  source    = "../../modules/iam_attachment"
  role_name = module.iam_role_ec2.attrs.name

  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

# cognito role
module "iam_role_cognito_auth" {
  source    = "../../modules/iam_role"
  role_name = "${local.name_prefix}-cognito-auth"

  assume_role_statements = [
    {
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"
      Principal = {
        Federated = "cognito-identity.amazonaws.com"
      }
      Condition = {
        StringEquals = {
          "cognito-identity.amazonaws.com:aud" = module.cognito_line_oidc.attrs.identity_pool_id
        },
        "ForAnyValue:StringLike" = {
          "cognito-identity.amazonaws.com:amr" = "authenticated"
        }
      }
    }
  ]
}

# cognito attachment
module "iam_attachment_cognito_auth" {
  source    = "../../modules/iam_attachment"
  role_name = module.iam_role_cognito_auth.attrs.name

  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
  ]
}

# ecs task execution role
module "iam_role_ecs_task_exec" {
  source    = "../../modules/iam_role"
  role_name = "${local.name_prefix}-ecs-task-exec"

  assume_role_statements = [
    {
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = ["ecs-tasks.amazonaws.com"]
      }
    }
  ]
}

# ecs task execution policy
module "iam_policy_ecs_task_exec" {
  source      = "../../modules/iam_policy"
  policy_name = "${local.name_prefix}-ecs-task-exec"
  role_id     = module.iam_role_ecs_task_exec.attrs.id

  policy_statements = [
    {
      sid    = "AllowGetSsmParams"
      effect = "Allow"
      actions = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath"
      ]
      resources = ["*"]
    },
    {
      sid    = "AllowCreateLogs"
      effect = "Allow"
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      resources = ["*"]
    },
    {
      sid    = "AllowUseEcr"
      effect = "Allow"
      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:CompleteLayerUpload",
        "ecr:DescribeImages",
        "ecr:DescribeRepositories",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:InitiateLayerUpload",
        "ecr:ListImages",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ]
      resources = ["${module.ecr_repo.attrs.arn}"]
    }
  ]
}

# ecs task execution attachment
module "iam_attachment_ecs_task_exec" {
  source    = "../../modules/iam_attachment"
  role_name = module.iam_role_ecs_task_exec.attrs.name

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

# ecs task role
module "iam_role_ecs_task" {
  source    = "../../modules/iam_role"
  role_name = "${local.name_prefix}-ecs-task"

  assume_role_statements = [
    {
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = ["ecs-tasks.amazonaws.com"]
      }
    }
  ]
}

# ecs task policy
module "iam_policy_ecs_task" {
  source      = "../../modules/iam_policy"
  policy_name = "${local.name_prefix}-ecs-task"
  role_id     = module.iam_role_ecs_task.attrs.id

  policy_statements = [
    {
      effect = "Allow"
      actions = [
        "rds:ListTagsForResource",
        "rds:DescribeDBClusters",
        "rds:DescribeDBInstances",
        "rds:DescribeDBSubnetGroups",
        "rds:DescribeDBSnapshots",
        "rds:DescribeDBClusterSnapshots",
        "rds:DescribeDBClusterParameters",
        "rds:DescribeDBClusterEndpoints",
        "rds:DescribeDBClusterMembers",
        "rds-db:connect",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:GetObjectVersion",
        "s3:PutObjectVersion",
        "s3:GetBucketLocation"
      ]
      resources = ["*"]
    }
  ]
}

# lambda exec role
module "iam_role_lambda_exec" {
  source    = "../../modules/iam_role"
  role_name = "${local.name_prefix}-lambda-exec"

  assume_role_statements = [
    {
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = ["lambda.amazonaws.com"]
      }
    }
  ]
}

# lambda ses policy
module "iam_policy_lambda_ses" {
  source      = "../../modules/iam_policy"
  policy_name = "${local.name_prefix}-lambda-ses"
  role_id     = module.iam_role_lambda_exec.attrs.id

  policy_statements = [
    {
      effect = "Allow"
      actions = [
        "sns:Publish",
        "ses:SendEmail",
        "ses:SendRawEmail"
      ]
      resources = ["*"]
    }
  ]
}

# lambda cwlogs policy
module "iam_policy_lambda_cwlogs" {
  source      = "../../modules/iam_policy"
  policy_name = "${local.name_prefix}-lambda-cwlogs"
  role_id     = module.iam_role_lambda_exec.attrs.id

  policy_statements = [
    {
      effect = "Allow"
      actions = [
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:GetLogEvents",
        "logs:FilterLogEvents"
      ]
      resources = ["*"]
    }
  ]
}

# lambda exec attachment
module "iam_attachment_lambda_exec" {
  source    = "../../modules/iam_attachment"
  role_name = module.iam_role_lambda_exec.attrs.name

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}

# github actions role
module "iam_role_github_actions_oidc" {
  source    = "../../modules/iam_role"
  role_name = "${local.name_prefix}-github-actions-oidc"

  assume_role_statements = [
    {
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
      }
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
        }
      }
    }
  ]
}

# github actions policy
module "iam_policy_github_actions" {
  source      = "../../modules/iam_policy"
  policy_name = "${local.name_prefix}-github-actions"
  role_id     = module.iam_role_github_actions_oidc.attrs.id

  policy_statements = [
    {
      sid    = "AllowPassRole"
      effect = "Allow"
      actions = [
        "iam:PassRole"
      ]
      resources = [
        "arn:aws:iam::*:role/${module.iam_role_ecs_task.attrs.name}",
        "arn:aws:iam::*:role/${module.iam_role_ecs_task_exec.attrs.name}"
      ]
    },
    {
      sid    = "AllowExecEcs"
      effect = "Allow"
      actions = [
        "ecs:DescribeServices",
        "ecs:UpdateService",
        "ecs:DescribeTasks",
        "ecs:ListTasks",
        "ecs:DescribeTaskDefinition",
        "ecs:RegisterTaskDefinition",
        "ecs:TagResource"
      ]
      resources = ["*"]
    },
    {
      sid    = "AllowUseAdminOriginBucket"
      effect = "Allow"
      actions = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:GetObjectVersion",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:PutObjectVersion",
        "s3:DeleteObject"
      ]
      resources = [
        "${module.s3_bucket_admin_origin.attrs.arn}",
        "${module.s3_bucket_admin_origin.attrs.arn}/*"
      ]
    },
    {
      sid    = "AllowUseAdminDistribution"
      effect = "Allow"
      actions = [
        "cloudfront:ListDistributions",
        "cloudfront:GetDistribution",
        "cloudfront:GetDistributionConfig",
        "cloudfront:ListStreamingDistributions",
        "cloudfront:GetStreamingDistribution",
        "cloudfront:GetStreamingDistributionConfig",
        "cloudfront:ListInvalidations",
        "cloudfront:GetInvalidation",
        "cloudfront:CreateInvalidation"
      ]
      resources = [
        "${module.landing_page_cfd_admin.attrs.arn}"
      ]
    }
  ]
}