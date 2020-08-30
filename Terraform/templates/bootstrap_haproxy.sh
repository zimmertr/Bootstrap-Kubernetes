#!/bin/bash
# HAProxy is initially configured with a template that does not provide any upstrema endpoint
# for load balanced traffic. The role of this script is to iterate over this configuration file
# and add these entries dynamically based on the number of control plane nodes. Basic logging
# is enabled and the resultant logs can be found in `/var/log/tks`. The configuration files for
# TKS can also be found in `/etc/tks/`.

main(){
  sudo mkdir /var/log/tks
  sudo chown tks:tks /var/log/tks
  debug > /var/log/tks/debug.log 2>&1
  configure_hostname > /var/log/tks/configure_hostname.log 2>&1
  disable_kubelet > /var/log/tks/disable_kubelet.log 2>&1
  configure_haproxy > /var/log/tks/configure_haproxy.log 2>&1
  deploy_haproxy > /var/log/tks/deploy_haproxy.log 2>&1
}

debug(){
  echo "TKS - DEBUG - $(date) - k8s_cp_hostname_prefix: ${k8s_cp_hostname_prefix}"
  echo "TKS - DEBUG - $(date) - haproxy_hostname: ${haproxy_hostname}"
  echo "TKS - DEBUG - $(date) - search_domain: ${search_domain}"
}

configure_hostname(){
  echo "TKS - $(date) - Setting the hostname."
  sudo hostnamectl set-hostname ${haproxy_hostname}.${search_domain}
}

disable_kubelet(){
  echo "TKS - $(date) - Disabling the Kubelet service."
  sudo systemctl disable --now kubelet
}

configure_haproxy(){
  echo "TKS - $(date) - Updating the HAProxy configuration file."
  for n in {1..${k8s_node_num}}; do
    echo "        server ${k8s_cp_hostname_prefix}-$n ${k8s_cp_hostname_prefix}-$n.${search_domain}:6443" >> /etc/tks/haproxy.cfg
    echo "TKS - $(date) - ${k8s_cp_hostname_prefix}-$n has been added to the HAProxy configuration file."
  done
}

deploy_haproxy(){
  echo "TKS - $(date) - Deploying the HAProxy Docker container."
  sudo docker run --restart=always -d -p 6443:6443 --name haproxy -v /etc/tks/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro haproxy:${haproxy_version}
}

main
