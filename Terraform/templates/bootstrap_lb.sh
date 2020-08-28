#!/bin/bash
if ! grep ${searchdomain} /etc/tks/haproxy.cfg; then
  sudo hostnamectl set-hostname ${lb_hn}.${searchdomain}
  sudo systemctl disable --now kubelet

  for n in {1..${node_num}}; do
    echo "        server ${cp_hn_prefix}-$n ${cp_hn_prefix}-$n.${searchdomain}:6443" >> /etc/tks/haproxy.cfg
  done

  sudo docker run --restart=always -d -p 6443:6443 --name haproxy -v /etc/tks/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro haproxy:${lb_version}
fi
