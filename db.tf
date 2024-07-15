resource "aws_db_instance" "primary_db" {
  provider                  = aws.primary
  allocated_storage         = 20
  engine                    = "mysql"
  engine_version            = "8.0"
  instance_class            = var.db_instance_class
  name                      = var.db_name
  username                  = var.db_username
  password                  = var.db_password
  parameter_group_name      = "default.mysql8.0"
  multi_az                  = true
  storage_encrypted         = true
  backup_retention_period   = 7
  deletion_protection       = true
  vpc_security_group_ids    = [aws_security_group.db_sg.id]
  db_subnet_group_name      = aws_db_subnet_group.primary_db_subnet_group.name

  tags = {
    Name = "PrimaryDB"
  }
}

resource "aws_db_instance" "secondary_db" {
  provider                  = aws.secondary
  allocated_storage         = 20
  engine                    = "mysql"
  engine_version            = "8.0"
  instance_class            = var.db_instance_class
  name                      = var.db_name
  username                  = var.db_username
  password                  = var.db_password
  parameter_group_name      = "default.mysql8.0"
  multi_az                  = true
  storage_encrypted         = true
  backup_retention_period   = 7
  deletion_protection       = true
  vpc_security_group_ids    = [aws_security_group.secondary_db_sg.id]
  db_subnet_group_name      = aws_db_subnet_group.secondary_db_subnet_group.name

  tags = {
    Name = "SecondaryDB"
  }
}

resource "aws_db_subnet_group" "primary_db_subnet_group" {
  name       = "primary-db-subnet-group"
  subnet_ids = [for s in aws_subnet.db : s.id]

  tags = {
    Name = "PrimaryDBSubnetGroup"
  }
}

resource "aws_db_subnet_group" "secondary_db_subnet_group" {
  provider   = aws.secondary
  name       = "secondary-db-subnet-group"
  subnet_ids = [for s in aws_subnet.secondary_db : s.id]

  tags = {
    Name = "SecondaryDBSubnetGroup"
  }
}
