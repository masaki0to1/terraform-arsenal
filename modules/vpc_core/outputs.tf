output "vpc" {
  value = {
    id   = aws_vpc.main.id
    cidr = aws_vpc.main.cidr_block
  }
}

output "private_subnets" {
  description = "map for private subnets"
  value = {
    for k, subnet in aws_subnet.private : k => {
      id                = subnet.id
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
    }
  }
}

output "public_subnets" {
  description = "map for public subnets"
  value = {
    for k, subnet in aws_subnet.public : k => {
      id                = subnet.id
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
    }
  }
}
