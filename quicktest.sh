#!/bin/bash
curl -vvv $(terraform output -raw ptg-generated-public-ip):8080
