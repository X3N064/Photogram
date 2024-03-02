resource "aws_db_instance" "photogram_DB" {
  allocated_storage      = 10
  db_name                = "photogram"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = "Qwer1234**"
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = [aws_security_group.allow_mysql.id]
  skip_final_snapshot    = true
}