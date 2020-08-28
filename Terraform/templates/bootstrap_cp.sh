#!/bin/bash
main(){
  sudo mkdir /var/log/tks
  sudo chown tks:tks /var/log/tks
  debug > /var/log/tks/debug.log 2>&1
  configure_hostname > /var/log/tks/configure_hostname.log 2>&1

  hostname=$(hostname -f)
  if [ $hostname == "${cp_hn_prefix}-1.${searchdomain}" ]; then
    init_primary_cp > /var/log/tks/init_primary_cp.log 2>&1
  else
    init_secondary_cp > /var/log/tks/init_secondary_cp.log 2>&1
  fi

  copy_cluster_config
  deploy_cni > /var/log/tks/deploy_cni.log 2>&1
}

debug(){
  echo "TKS - DEBUG - $(date) - cp_hn_prefix: ${cp_hn_prefix}"
  echo "TKS - DEBUG - $(date) - lb_hn: ${lb_hn}"
  echo "TKS - DEBUG - $(date) - searchdomain: ${searchdomain}"
  echo "TKS - DEBUG - $(date) - count_index: ${count_index + 1}"
}

configure_hostname(){
  echo "TKS - $(date) - Setting the hostname."
  sudo hostnamectl set-hostname ${cp_hn_prefix}-${count_index + 1}.${searchdomain}
}

init_primary_cp(){
  echo "TKS - $(date) - Initializing the Control Plane node."
  sudo kubeadm init --config /etc/tks/cp_configuration_primary.yml --upload-certs -v=9
  echo "TKS - $(date) - The initial Control Plane node is now available."
}

init_secondary_cp(){
  while ! curl https://${cp_hn_prefix}-1.${searchdomain}:6443 -k -I; do
    echo "TKS - $(date) - The initial Control Plane node is not yet available."
  done
  echo "TKS - $(date) - The initial Control Plane node is now available."


  echo "TKS - $(date) - Joining the secondary Control Plane node to the cluster."
  sudo kubeadm join --config /etc/tks/cp_configuration_secondary.yml -v=9
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
