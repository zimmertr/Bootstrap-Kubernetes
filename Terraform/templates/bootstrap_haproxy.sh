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
  echo "TKS - DEBUG - $(date) - K8S_CP_HOSTNAME_PREFIX: ${K8S_CP_HOSTNAME_PREFIX}"
  echo "TKS - DEBUG - $(date) - HAPROXY_HOSTNAME: ${HAPROXY_HOSTNAME}"
  echo "TKS - DEBUG - $(date) - TKS_SEARCH_DOMAIN: ${TKS_SEARCH_DOMAIN}"
}

configure_hostname(){
  echo "TKS - $(date) - Setting the hostname."
  sudo hostnamectl set-hostname ${HAPROXY_HOSTNAME}.${TKS_SEARCH_DOMAIN}
}

disable_kubelet(){
  echo "TKS - $(date) - Disabling the Kubelet service."
  sudo systemctl disable --now kubelet
}

configure_haproxy(){
  echo "TKS - $(date) - Updating the HAProxy configuration file."
  for n in {1..${K8S_NODE_NUM}}; do
    echo "        server ${K8S_CP_HOSTNAME_PREFIX}-$n ${K8S_CP_HOSTNAME_PREFIX}-$n.${TKS_SEARCH_DOMAIN}:6443" >> /etc/tks/haproxy.cfg
    echo "TKS - $(date) - ${K8S_CP_HOSTNAME_PREFIX}-$n has been added to the HAProxy configuration file."
  done
}

deploy_haproxy(){
  echo "TKS - $(date) - Deploying the HAProxy Docker container."
  sudo docker run --restart=always -d -p 6443:6443 --name haproxy -v /etc/tks/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro haproxy:${HAPROXY_VERSION}
}

main
