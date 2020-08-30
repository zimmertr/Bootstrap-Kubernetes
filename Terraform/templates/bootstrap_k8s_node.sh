#!/bin/bash
# Basic logging is enabled and the resultant logs can be found inn `/var/log/tks`.
# The configuration files for TKS can also be found in `/etc/tks/`.

main(){
  sudo mkdir /var/log/tks
  sudo chown tks:tks /var/log/tks
  debug > /var/log/tks/debug.log 2>&1
  configure_hostname > /var/log/tks/configure_hostname.log 2>&1
  init_worker_node > /var/log/tks/init_worker_node.log 2>&1
}

debug(){
  echo "TKS - DEBUG - $(date) - K8S_NODE_HOSTNAME_PREFIX: ${K8S_NODE_HOSTNAME_PREFIX}"
  echo "TKS - DEBUG - $(date) - TKS_SEARCH_DOMAIN: ${TKS_SEARCH_DOMAIN}"
  echo "TKS - DEBUG - $(date) - COUNT_INDEX: ${COUNT_INDEX + 1}"
}

configure_hostname(){
  echo "TKS - $(date) - Setting the hostname."
  sudo hostnamectl set-hostname ${K8S_NODE_HOSTNAME_PREFIX}-${COUNT_INDEX + 1}.${TKS_SEARCH_DOMAIN}
}

init_worker_node(){
  echo "TKS - $(date) - Initializing the worker node node."
  sudo kubeadm join --config /etc/tks/k8s_node_configuration.yml -v=9
  echo "TKS - $(date) - The worker node is now available."
}

main
