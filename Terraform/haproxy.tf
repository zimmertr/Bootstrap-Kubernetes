resource "proxmox_vm_qemu" "k8s-lb" {
  vmid       = var.HAPROXY_VMID
  name       = var.HAPROXY_HOSTNAME
  clone      = var.TKS_TEMPLATE_NAME
  full_clone = var.HAPROXY_FULL_CLONE

  target_node = var.PROXMOX_HOSTNAME
  pool        = var.TKS_RESOURCE_POOL


  sockets = var.HAPROXY_SOCKETS
  cores   = var.HAPROXY_CORES
  memory  = var.HAPROXY_MEMORY

  network {
    id     = 0
    model  = var.TKS_NET_TYPE
    bridge = var.TKS_NET_BRIDGE
    tag    = var.TKS_VLAN_ID
  }

  disk {
    id           = 0
    storage      = var.TKS_STORAGE
    storage_type = var.TKS_STORAGE_TYPE
    type         = var.TKS_DISK_TYPE
    size         = var.TKS_DISK_SIZE
    backup       = var.TKS_ENABLE_BACKUPS
    iothread     = true
  }

  onboot = var.TKS_ENABLE_ONBOOT
  agent  = 1

  os_type      = "cloud-init"
  ipconfig0    = "ip=${var.HAPROXY_IP_ADDRESS}/${var.TKS_SUBNET_SIZE},gw=${var.TKS_GATEWAY}"
  nameserver   = var.TKS_NAMESERVER
  searchdomain = var.TKS_SEARCH_DOMAIN

  connection {
    type        = "ssh"
    user        = var.TKS_TEMPLATE_USERNAME
    host        = var.HAPROXY_IP_ADDRESS
    private_key = file(var.TKS_SSH_PRIVATE_KEY_PATH)
  }

  provisioner "file" {
    destination = "/etc/tks/haproxy.cfg"
    content = templatefile("./templates/haproxy.cfg", {
      HAPROXY_STATS_ENABLE   = var.HAPROXY_STATS_ENABLE
      HAPROXY_STATS_USERNAME = var.HAPROXY_STATS_USERNAME
      HAPROXY_STATS_PASSWORD = var.HAPROXY_STATS_PASSWORD
    })
  }
}


resource "null_resource" "bootstrap_lb" {
  depends_on = [
    proxmox_vm_qemu.k8s-lb
  ]

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = var.TKS_TEMPLATE_USERNAME
      host        = var.HAPROXY_IP_ADDRESS
      private_key = file(var.TKS_SSH_PRIVATE_KEY_PATH)
    }
    destination = "/etc/tks/bootstrap_haproxy.sh"
    content = templatefile("./templates/bootstrap_haproxy.sh", {
      HAPROXY_HOSTNAME       = var.HAPROXY_HOSTNAME
      HAPROXY_VERSION        = var.HAPROXY_VERSION
      TKS_SEARCH_DOMAIN      = var.TKS_SEARCH_DOMAIN
      K8S_CP_HOSTNAME_PREFIX = var.K8S_CP_HOSTNAME_PREFIX
      K8S_NODE_NUM           = var.K8S_NODE_NUM
    })
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.TKS_TEMPLATE_USERNAME
      host        = var.HAPROXY_IP_ADDRESS
      private_key = file(var.TKS_SSH_PRIVATE_KEY_PATH)
    }
    inline = ["bash /etc/tks/bootstrap_haproxy.sh"]
  }
}
