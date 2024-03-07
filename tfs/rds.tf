# Create RDS instance
resource "aws_db_instance" "photogram_rds" {
  identifier             = "photogram-rds"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = "Qwer1234**" # put your own password here
  publicly_accessible    = false
  multi_az               = false
  vpc_security_group_ids = [aws_security_group.photogram_mysql_sg.id]
  db_subnet_group_name   = "default"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  tags = {
    Name = "photogram-rds"
  }
}
