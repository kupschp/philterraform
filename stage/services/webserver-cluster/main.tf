module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name = "stage-ptg-webservers"
  db_remote_state_bucket = "ptg-tfstate"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  cluster_min_size = 2
  cluster_max_size = 4
}
