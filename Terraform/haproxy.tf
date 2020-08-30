resource "proxmox_vm_qemu" "k8s-lb" {
  vmid       = var.haproxy_vmid
  name       = var.haproxy_hostname
  clone      = var.template_name
  full_clone = var.haproxy_full_clone

  target_node = var.proxmox_hostname
  pool        = var.resource_pool


  sockets = var.haproxy_sockets
  cores   = var.haproxy_cores
  memory  = var.haproxy_memory

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

  os_type      = "cloud-init"
  ipconfig0    = "ip=${var.haproxy_ip_address}/${var.subnet_size},gw=${var.gateway}"
  nameserver   = var.nameserver
  searchdomain = var.search_domain

  connection {
    type        = "ssh"
    user        = var.template_username
    host        = var.haproxy_ip_address
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    source      = "./templates/haproxy.cfg"
    destination = "/etc/tks/haproxy.cfg"
  }
}


resource "null_resource" "bootstrap_lb" {
  depends_on = [
    proxmox_vm_qemu.k8s-lb
  ]

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = var.template_username
      host        = var.haproxy_ip_address
      private_key = file(var.ssh_private_key_path)
    }
    destination = "/etc/tks/bootstrap_haproxy.sh"
    content = templatefile("./templates/bootstrap_haproxy.sh", {
      haproxy_hostname       = var.haproxy_hostname
      haproxy_version        = var.haproxy_version
      search_domain          = var.search_domain
      k8s_cp_hostname_prefix = var.k8s_cp_hostname_prefix
      k8s_node_num           = var.k8s_node_num
    })
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.template_username
      host        = var.haproxy_ip_address
      private_key = file(var.ssh_private_key_path)
    }
    inline = ["bash /etc/tks/bootstrap_haproxy.sh"]
  }
}
