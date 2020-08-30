resource "proxmox_vm_qemu" "k8s-cp" {
  depends_on = [
    proxmox_vm_qemu.k8s-lb
  ]
  count      = var.k8s_cp_num
  vmid       = var.k8s_cp_vmid + count.index
  name       = "${var.k8s_cp_hostname_prefix}-${count.index + 1}"
  clone      = var.template_name
  full_clone = var.k8s_cp_full_clone

  target_node = var.proxmox_hostname
  pool        = var.resource_pool


  sockets = var.k8s_cp_sockets
  cores   = var.k8s_cp_cores
  memory  = var.k8s_cp_memory

  network {
    id     = 0
    model  = var.net_type
    bridge = var.net_bridge
    tag    = var.vlan_id
  }

  disk {
    id           = 0
    storage      = var.storage
    storage_type = var.storage_type
    type         = var.disk_type
    size         = var.disk_size
    backup       = var.enable_backups
    iothread     = true
  }

  onboot = var.enable_onboot
  agent  = 1

  os_type = "cloud-init"
  # ipconfig0    = "ip=${var.k8s_cp_ip_address}/${var.subnet_size},gw=${var.gateway}"
  # Telmate Terraform provider does not support dynamic IP Addresses with `count`.
  # As a result, the below is used as a workaround. This introduces a node limitation of 9.
  ipconfig0    = "ip=${var.ip_prefix}.${count.index + var.k8s_cp_ip_suffix}/${var.subnet_size},gw=${var.gateway}"
  nameserver   = var.nameserver
  searchdomain = var.search_domain

  provisioner "file" {
    destination = "/etc/tks/bootstrap_k8s_cp.sh"
    connection {
      type        = "ssh"
      user        = var.template_username
      host        = "${var.ip_prefix}.${count.index + var.k8s_cp_ip_suffix}"
      private_key = file(var.ssh_private_key_path)
    }
    content = templatefile("./templates/bootstrap_k8s_cp.sh", {
      haproxy_hostname       = var.haproxy_hostname
      search_domain          = var.search_domain
      k8s_cp_hostname_prefix = var.k8s_cp_hostname_prefix
      count_index            = count.index
    })
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.template_username
      host        = "${var.ip_prefix}.${count.index + var.k8s_cp_ip_suffix}"
      private_key = file(var.ssh_private_key_path)
    }
    inline = ["bash /etc/tks/bootstrap_k8s_cp.sh"]
  }
}
