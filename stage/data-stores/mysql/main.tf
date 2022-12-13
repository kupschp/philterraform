resource "aws_db_instance" "ptg-db" {
    identifier_prefix = "ptg-db"
    engine = "mysql"
    allocated_storage = 10
    instance_class = "db.t2.micro"
    skip_final_snapshot = true
    db_name = "ptg"

    #tbd in next chapter of the book, store secrets such as username and password securely somewhere, 
    #temporarily using local envt variable - not recommended
    username = var.ptg_db_username
    password = var.ptg_db_password
}