resource "proxmox_vm_qemu" "k8s-cp" {
  depends_on = [
    proxmox_vm_qemu.k8s-lb
  ]
  count      = var.K8S_CP_NUM
  vmid       = var.K8S_CP_VMID + count.index
  name       = "${var.K8S_CP_HOSTNAME_PREFIX}-${count.index + 1}"
  clone      = var.TKS_TEMPLATE_NAME
  full_clone = var.K8S_CP_FULL_CLONE

  target_node = var.PROXMOX_HOSTNAME
  pool        = var.TKS_RESOURCE_POOL

  sockets = var.K8S_CP_SOCKETS
  cores   = var.K8S_CP_CORES
  memory  = var.K8S_CP_MEMORY

  network {
    model  = var.TKS_NET_TYPE
    bridge = var.TKS_NET_BRIDGE
    tag    = var.TKS_VLAN_ID
  }

  disk {
    storage      = var.TKS_STORAGE
    type         = var.TKS_DISK_TYPE
    size         = var.TKS_DISK_SIZE
    backup       = var.TKS_ENABLE_BACKUPS
    iothread     = 0
  }

  onboot = var.TKS_ENABLE_ONBOOT
  agent  = 1

  os_type = "cloud-init"
  # Telmate Terraform provider does not support dynamic IP Addresses with `count`.
  # As a result, the below is used as a workaround. This introduces a node limitation of 9.
  ipconfig0    = "ip=${var.TKS_IP_PREFIX}.${count.index + var.K8S_CP_IP_SUFFIX}/${var.TKS_SUBNET_SIZE},gw=${var.TKS_GATEWAY}"
  nameserver   = var.TKS_NAMESERVER
  searchdomain = var.TKS_SEARCH_DOMAIN

  provisioner "file" {
    destination = "/etc/tks/bootstrap_k8s_cp.sh"
    connection {
      type        = "ssh"
      user        = var.TKS_TEMPLATE_USERNAME
      host        = "${var.TKS_IP_PREFIX}.${count.index + var.K8S_CP_IP_SUFFIX}"
      private_key = file(var.TKS_SSH_PRIVATE_KEY_PATH)
    }
    content = templatefile("${path.root}/templates/bootstrap_k8s_cp.sh", {
      HAPROXY_HOSTNAME       = var.HAPROXY_HOSTNAME
      TKS_SEARCH_DOMAIN      = var.TKS_SEARCH_DOMAIN
      K8S_CP_HOSTNAME_PREFIX = var.K8S_CP_HOSTNAME_PREFIX
      COUNT_INDEX            = count.index
    })
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.TKS_TEMPLATE_USERNAME
      host        = "${var.TKS_IP_PREFIX}.${count.index + var.K8S_CP_IP_SUFFIX}"
      private_key = file(var.TKS_SSH_PRIVATE_KEY_PATH)
    }
    inline = ["bash /etc/tks/bootstrap_k8s_cp.sh"]
  }
}
