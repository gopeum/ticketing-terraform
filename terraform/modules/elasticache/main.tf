locals {
  name = "${var.env}-ticketing-redis"
}

# Subnet Group

resource "aws_elasticache_subnet_group" "main" {
  name       = "${local.name}-subnet-group"
  subnet_ids = var.subnet_ids
}

# Parameter Group

resource "aws_elasticache_parameter_group" "redis" {
  name   = "${local.name}-param"
  family = "redis7"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }
}

# Redis Replication Group

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = local.name
  description          = "Ticketing Redis"

  engine         = "redis"
  engine_version = "7.0"
  node_type      = "cache.t3.micro"
  port           = 6379

  num_node_groups         = 1
  replicas_per_node_group = 1

  automatic_failover_enabled = true
  multi_az_enabled           = true

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [var.security_group_id]

  parameter_group_name = aws_elasticache_parameter_group.redis.name

  # 보안
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  snapshot_retention_limit = 0

  tags = {
    Name        = local.name
    Environment = var.env
  }
}