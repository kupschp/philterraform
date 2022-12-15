module "database_instance" {
  source = "../../../modules/data-stores/mysql"

  #username and password temporary, will move it into secret storage for next chapter of the book
  db_username = "prod_usrptgtest"
  db_password = "prod_pwdptgtest"
  db_instance_type = "db.t2.micro"
  db_storage_size = 10
  identifier_prefix = "prod-ptg"
  db_name = "prod_ptg"
}