variable "regions" {
  description = "List of AWS regions"
  type        = list(string)
  default     = ["us-west-2", "us-east-1"]
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR block"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR block"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "db_subnet_cidr" {
  description = "Database subnet CIDR block"
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "db_instance_class" {
  description = "RDS instance class"
  default     = "db.t2.micro"
}

variable "db_name" {
  description = "Database name"
  default     = "mydb"
}

variable "db_username" {
  description = "Database username"
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  default     = "password"
  sensitive   = true
}

