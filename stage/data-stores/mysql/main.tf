module "database_instance" {
  source = "../../../modules/data-stores/mysql"

  #will store usrname and password in secret management in next chapter of the book
  db_username = "stage_usrptgtest"
  db_password = "stage_pwdptgtest"
  db_instance_type = "db.t2.micro"
  identifier_prefix = "stage-ptg"
  db_name = "stage_ptg"
  db_storage_size = 10
}