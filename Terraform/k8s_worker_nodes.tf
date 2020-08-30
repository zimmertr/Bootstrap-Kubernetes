resource "proxmox_vm_qemu" "k8s-nodes" {
  depends_on = [
    proxmox_vm_qemu.k8s-cp
  ]
  count      = var.K8S_NODE_NUM
  vmid       = var.K8S_NODE_VMID + count.index
  name       = "${var.K8S_NODE_HOSTNAME_PREFIX}-${count.index + 1}"
  clone      = var.TKS_TEMPLATE_NAME
  full_clone = var.K8S_NODE_FULL_CLONE

  target_node = var.PROXMOX_HOSTNAME
  pool        = var.TKS_RESOURCE_POOL

  sockets = var.K8S_NODE_SOCKETS
  cores   = var.K8S_NODE_CORES
  memory  = var.K8S_NODE_MEMORY

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

  os_type = "cloud-init"
  # Telmate Terraform provider does not support dynamic IP Addresses with `count`.
  # As a result, the below is used as a workaround. This introduces a node limitation of 9.
  ipconfig0 = "ip=${var.TKS_IP_PREFIX}.${count.index + var.K8S_NODE_IP_SUFFIX}/${var.TKS_SUBNET_SIZE},gw=${var.TKS_GATEWAY}"
  # nameserver   = var.TKS_NAMESERVER
  searchdomain = var.TKS_SEARCH_DOMAIN

  connection {
    type        = "ssh"
    user        = var.TKS_TEMPLATE_USERNAME
    host        = "${var.TKS_IP_PREFIX}.${count.index + var.K8S_NODE_IP_SUFFIX}"
    private_key = file("/Users/tj/.ssh/Sol.Milkyway/kubernetes.sol.milkyway")
  }

  provisioner "file" {
    destination = "/etc/tks/bootstrap_k8s_node.sh"
    content = templatefile("./templates/bootstrap_k8s_node.sh", {
      TKS_SEARCH_DOMAIN        = var.TKS_SEARCH_DOMAIN
      K8S_NODE_HOSTNAME_PREFIX = var.K8S_NODE_HOSTNAME_PREFIX
      COUNT_INDEX              = count.index
    })
  }
  provisioner "remote-exec" {
    inline = ["bash /etc/tks/bootstrap_k8s_node.sh"]
  }
}
