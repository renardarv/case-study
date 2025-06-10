#!/bin/bash

if [[ $(cat /etc/os-release  | grep -i id | cut -d'=' -f2 | awk 'NR==1' | tr -d '"') == "ubuntu" ]]; then

  cd /home/ubuntu

  sudo apt update -y
  sudo apt install -y nginx certbot nfs-kernel-server
  sudo systemctl start nginx

fi

if [[ $(cat /etc/os-release  | grep -i id | cut -d'=' -f2 | awk 'NR==1' | tr -d '"') == "amzn" ]]; then

  cd /home/ec2-user

  sudo amazon-linux-extras install -y nginx1 nfs-utils
  sudo systemctl start nginx

fi
