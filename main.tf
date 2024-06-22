resource "aws_db_instance" "example" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "12.4"
  instance_class       = "db.t3.micro"
  db_name                 = "mydatabase"
  username             = "rudraksh"
  password             = "barbazqux"
  parameter_group_name = "default.postgres12"
  skip_final_snapshot  = true
}
