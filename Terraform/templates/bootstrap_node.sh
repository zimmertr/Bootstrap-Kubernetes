#!/bin/bash
sudo hostnamectl set-hostname ${node_hn_prefix}-${count_index + 1}.${searchdomain}
sudo kubeadm join --config /etc/tks/node_configuration.yml
