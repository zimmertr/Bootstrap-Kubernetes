#!/bin/bash
# Kubeadm bootstrapping occurs differently depending on the role of the node in the cluster.
# For the most part, you can look at this in three primary ways. Initial CP, Additional CP,
# and the worker nodes. When initializing a cluster, it is necessary to run a different
# command based on which of these three roles the target node will fulfill. This the
# requirement for this script. Basic logging is enabled and the resultant logs can be found
# in `/var/log/tks`. The configuration files for TKS can also be found in `/etc/tks/`.

main(){
  sudo mkdir /var/log/tks
  sudo chown tks:tks /var/log/tks
  debug > /var/log/tks/debug.log 2>&1
  configure_hostname > /var/log/tks/configure_hostname.log 2>&1

  hostname=$(hostname -f)
  if [ $hostname == "${k8s_cp_hostname_prefix}-1.${search_domain}" ]; then
    init_primary_cp > /var/log/tks/init_primary_cp.log 2>&1
  else
    init_secondary_cp > /var/log/tks/init_secondary_cp.log 2>&1
  fi

  copy_cluster_config
  deploy_cni > /var/log/tks/deploy_cni.log 2>&1
}

debug(){
  echo "TKS - DEBUG - $(date) - k8s_cp_hostname_prefix: ${k8s_cp_hostname_prefix}"
  echo "TKS - DEBUG - $(date) - haproxy_hostname: ${haproxy_hostname}"
  echo "TKS - DEBUG - $(date) - search_domain: ${search_domain}"
  echo "TKS - DEBUG - $(date) - count_index: ${count_index + 1}"
}

configure_hostname(){
  echo "TKS - $(date) - Setting the hostname."
  sudo hostnamectl set-hostname ${k8s_cp_hostname_prefix}-${count_index + 1}.${search_domain}
}

init_primary_cp(){
  echo "TKS - $(date) - Initializing the Control Plane node."
  sudo kubeadm init --config /etc/tks/k8s_cp_configuration_primary.yml --upload-certs -v=9
  echo "TKS - $(date) - The initial Control Plane node is now available."
}

init_secondary_cp(){
  while ! curl https://${k8s_cp_hostname_prefix}-1.${search_domain}:6443 -k -I; do
    echo "TKS - $(date) - The initial Control Plane node is not yet available."
  done
  echo "TKS - $(date) - The initial Control Plane node is now available."


  echo "TKS - $(date) - Joining the secondary Control Plane node to the cluster."
  sudo kubeadm join --config /etc/tks/k8s_cp_configuration_secondary.yml -v=9
  echo "TKS - $(date) - The secondary Control Plane node is now available"
}

copy_cluster_config(){
  mkdir /home/tks/.kube
  sudo cp /etc/kubernetes/admin.conf /home/tks/.kube/config
  sudo chown -R tks:tks /home/tks/.kube/
}

deploy_cni(){
  wget https://docs.projectcalico.org/v3.16/manifests/calico.yaml -O /etc/tks/calico.yaml
  sudo kubectl apply -f /etc/tks/calico.yaml --kubeconfig /etc/kubernetes/admin.conf
}

main
