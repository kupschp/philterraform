#!/bin/bash
curl -vvv $(terraform output -raw ptg_alb_dns_name)
