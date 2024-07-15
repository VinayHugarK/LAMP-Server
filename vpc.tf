resource "aws_vpc" "main" {
  provider   = aws.primary
  cidr_block = var.vpc_cidr

  tags = {
    Name = "MainVPC"
  }
}

resource "aws_vpc" "secondary_main" {
  provider   = aws.secondary
  cidr_block = var.vpc_cidr

  tags = {
    Name = "SecondaryVPC"
  }
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidr)
  provider          = aws.primary
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet${count.index + 1}"
  }
}

resource "aws_subnet" "secondary_public" {
  count             = length(var.public_subnet_cidr)
  provider          = aws.secondary
  vpc_id            = aws_vpc.secondary_main.id
  cidr_block        = var.public_subnet_cidr[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "SecondaryPublicSubnet${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr)
  provider          = aws.primary
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr[count.index]

  tags = {
    Name = "PrivateSubnet${count.index + 1}"
  }
}

resource "aws_subnet" "secondary_private" {
  count             = length(var.private_subnet_cidr)
  provider          = aws.secondary
  vpc_id            = aws_vpc.secondary_main.id
  cidr_block        = var.private_subnet_cidr[count.index]

  tags = {
    Name = "SecondaryPrivateSubnet${count.index + 1}"
  }
}

resource "aws_subnet" "db" {
  count             = length(var.db_subnet_cidr)
  provider          = aws.primary
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_subnet_cidr[count.index]

  tags = {
    Name = "DBSubnet${count.index + 1}"
  }
}

resource "aws_subnet" "secondary_db" {
  count             = length(var.db_subnet_cidr)
  provider          = aws.secondary
  vpc_id            = aws_vpc.secondary_main.id
  cidr_block        = var.db_subnet_cidr[count.index]

  tags = {
    Name = "SecondaryDBSubnet${count.index + 1}"
  }
}

resource "aws_internet_gateway" "gw" {
  provider = aws.primary
  vpc_id   = aws_vpc.main.id

  tags = {
    Name = "MainIGW"
  }
}

resource "aws_internet_gateway" "secondary_gw" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary_main.id

  tags = {
    Name = "SecondaryIGW"
  }
}

resource "aws_route_table" "public" {
  provider = aws.primary
  vpc_id   = aws_vpc.main.id

  tags = {
    Name = "MainPublicRT"
  }
}

resource "aws_route_table" "secondary_public" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary_main.id

  tags = {
    Name = "SecondaryPublicRT"
  }
}

resource "aws_route" "internet_access" {
  provider              = aws.primary
  route_table_id        = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id            = aws_internet_gateway.gw.id
}

resource "aws_route" "secondary_internet_access" {
  provider              = aws.secondary
  route_table_id        = aws_route_table.secondary_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id            = aws_internet_gateway.secondary_gw.id
}

resource "aws_route_table_association" "public" {
  count        = length(var.public_subnet_cidr)
  provider     = aws.primary
  subnet_id    = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "secondary_public" {
  count        = length(var.public_subnet_cidr)
  provider     = aws.secondary
  subnet_id    = aws_subnet.secondary_public[count.index].id
  route_table_id = aws_route_table.secondary_public.id
}

resource "aws_security_group" "web_sg" {
  provider = aws.primary
  vpc_id   = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebSG"
  }
}

resource "aws_security_group" "secondary_web_sg" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary_main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SecondaryWebSG"
  }
}

resource "aws_security_group" "app_sg" {
  provider = aws.primary
  vpc_id   = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AppSG"
  }
}

resource "aws_security_group" "secondary_app_sg" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary_main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [aws_security_group.secondary_web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SecondaryAppSG"
  }
}

resource "aws_security_group" "db_sg" {
  provider = aws.primary
  vpc_id   = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DBSG"
  }
}

resource "aws_security_group" "secondary_db_sg" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary_main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.secondary_app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SecondaryDBSG"
  }
}

