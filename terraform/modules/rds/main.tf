resource "aws_db_subnet_group" "main" {
  name       = "${var.env}-rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "${var.env}-rds-subnet-group"
    Environment = var.env
  }
}

# Primary DB (Writer)
resource "aws_db_instance" "writer" {
  identifier        = "${var.env}-ticketing-writer"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "ticketing"
  username = "admin" 
  password = var.db_password
  port     = 3306

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.security_group_id]

  publicly_accessible = false   
  multi_az            = false   # 비용 절감용 (필요시 true)

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = {
    Name        = "${var.env}-mysql-writer"
    Role        = "primary"
    Environment = var.env
  }
}

# Read Replica
resource "aws_db_instance" "reader" {
  identifier          = "${var.env}-ticketing-reader"
  replicate_source_db = aws_db_instance.writer.identifier
  instance_class      = "db.t3.micro"

  publicly_accessible = false

  skip_final_snapshot = true
  deletion_protection = false

  depends_on = [aws_db_instance.writer]

  tags = {
    Name        = "${var.env}-mysql-reader"
    Role        = "replica"
    Environment = var.env
  }
}

# SSM Parameter Store

resource "aws_ssm_parameter" "db_writer_endpoint" {
  name  = "/${var.env}/ticketing/db/writer-endpoint"
  type  = "String"
  value = aws_db_instance.writer.address
}

resource "aws_ssm_parameter" "db_reader_endpoint" {
  name  = "/${var.env}/ticketing/db/reader-endpoint"
  type  = "String"
  value = aws_db_instance.reader.address
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.env}/ticketing/db/password"
  type  = "SecureString"
  value = var.db_password
}