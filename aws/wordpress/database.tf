#make db subnet group 
resource "aws_db_subnet_group" "db_subnet" {
  name       = "main"
  subnet_ids = ["${aws_subnet.rds.*.id}"]
}

resource "aws_db_instance" "wp_db" {
  identifier             = "wp-db"
  instance_class         = "${var.rds_instance_type}"
  allocated_storage      = "${var.rds_storage_gb}"
  engine                 = "${var.rds_engine}"
  name                   = "wordpress_db"
  password               = "${var.db_password}"
  username               = "${var.db_user}"
  engine_version         = "${var.rds_engine_version}"
  skip_final_snapshot    = true
  db_subnet_group_name   = "${aws_db_subnet_group.db_subnet.name}"
  vpc_security_group_ids = ["${aws_security_group.wp_db.id}"]
}
