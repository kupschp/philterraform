resource "aws_db_instance" "ptg-db" {
    identifier_prefix = "${var.identifier_prefix}-db"
    engine = local.engine
    allocated_storage = var.db_storage_size
    instance_class = var.db_instance_type
    skip_final_snapshot = true
    db_name = var.db_name

    #tbd in next chapter of the book, store secrets such as username and password securely somewhere, 
    #temporarily using local envt variable - not recommended
    username = var.db_username
    password = var.db_password
}