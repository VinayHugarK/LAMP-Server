resource "aws_instance" "app" {
  provider         = aws.primary
  ami              = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
  instance_type    = var.instance_type
  subnet_id        = aws_subnet.private[0].id
  security_groups  = [aws_security_group.app_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install -y tomcat8.5
              sudo systemctl start tomcat
              sudo systemctl enable tomcat
              echo "<h1>App Layer - Primary</h1>" | sudo tee /usr/share/tomcat/webapps/ROOT/index.html
              EOF

  tags = {
    Name = "AppServerPrimary"
  }
}

resource "aws_instance" "secondary_app" {
  provider         = aws.secondary
  ami              = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
  instance_type    = var.instance_type
  subnet_id        = aws_subnet.secondary_private[0].id
  security_groups  = [aws_security_group.secondary_app_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install -y tomcat8.5
              sudo systemctl start tomcat
              sudo systemctl enable tomcat
              echo "<h1>App Layer - Secondary</h1>" | sudo tee /usr/share/tomcat/webapps/ROOT/index.html
              EOF

  tags = {
    Name = "AppServerSecondary"
  }
}
