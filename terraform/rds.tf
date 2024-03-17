terraform {
  backend "s3" {
    bucket = "techchallenge-rds-terraform"
    key = "terraform/terraform.tfstate"
    region = "us-east-1"
  }
}


provider "aws" {
  region  = "us-east-1"
  profile = "alex-ferreira-sam-developer"
}


# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}

# create security group for the database
resource "aws_security_group" "database_security_group" {
  name        = "database challenge security group"
  description = "enable mysql/aurora access on port 3306"
  vpc_id      = "vpc-0bb1700964a29886f"

  ingress {
    description      = "mysql/aurora access"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = ["sg-0318e2377365f440b"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "database challenge security group"
  }
}


# create the subnet group for the rds instance
resource "aws_db_subnet_group" "database_subnet_group" {
  name         = "database subnets"
  subnet_ids   = ["subnet-06c9f94e8b0c30339", "subnet-089fc6af66fd30288", "subnet-08fcb18acdf8db0e0", "subnet-03d791ee969d588d6", "subnet-0ca81aaf0e06d7356", "subnet-0ed73859eed465964"] 
  description  = "subnts database"

  tags   = {
    Name = "database subnets"
  }
}


# create the rds instance
resource "aws_db_instance" "db_instance" {
  engine                  = "mysql"
  engine_version          = "8.0.31"
  multi_az                = false
  identifier              = "challenge-rds-instance"
  username                = "challenge"
  password                = "challengeadmin"
  instance_class          = "db.t2.micro"
  allocated_storage       = 200
  db_subnet_group_name    = aws_db_subnet_group.database_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.database_security_group.id]
  availability_zone       = "us-east-1a"
  publicly_accessible     = true
  db_name                 = "challengeDatabaseRds"
  skip_final_snapshot     = true
}