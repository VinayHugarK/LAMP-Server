resource "aws_instance" "web" {
  provider         = aws.primary
  ami              = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
  instance_type    = var.instance_type
  subnet_id        = aws_subnet.public[0].id
  security_groups  = [aws_security_group.web_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "<h1>Web Layer - Primary</h1>" | sudo tee /var/www/html/index.html
              EOF

  tags = {
    Name = "WebServerPrimary"
  }
}

resource "aws_instance" "secondary_web" {
  provider         = aws.secondary
  ami              = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
  instance_type    = var.instance_type
  subnet_id        = aws_subnet.secondary_public[0].id
  security_groups  = [aws_security_group.secondary_web_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "<h1>Web Layer - Secondary</h1>" | sudo tee /var/www/html/index.html
              EOF

  tags = {
    Name = "WebServerSecondary"
  }
}
