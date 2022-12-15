module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name = "prod-ptg-webservers"
  db_remote_state_bucket = "ptg-tfstate"
  db_remote_state_key = "prod/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.medium"
  cluster_min_size = 3
  cluster_max_size = 5
}

#scheduled scale in and out of prod cluter: more traffic at 9am: 4 vm instances,less traffic at 5pm:2 vm instances
resource "aws_autoscaling_schedule" "scale_out_at_high_peak" {
  scheduled_action_name = "scale-out-at-high-peak"
  min_size = 2
  max_size = 4
  desired_capacity = 4
  recurrence = "0 9 * * *"

  autoscaling_group_name = module.webserver_cluster.asg_name
}

resource "aws_autoscaling_schedule" "scale_in_at_low_peak" {
  scheduled_action_name = "scale-in-at-low-peak"
  min_size = 2
  max_size = 4
  desired_capacity = 2
  recurrence = "0 17 * * *"

  autoscaling_group_name = module.webserver_cluster.asg_name
}
