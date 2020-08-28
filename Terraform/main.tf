provider "proxmox" {
  pm_parallel     = 8
  pm_tls_insecure = true
  pm_api_url      = "https://${var.proxmox_hostname}:${var.proxmox_port}/api2/json"
  pm_user         = var.proxmox_user
  pm_password     = var.proxmox_password
}


resource "proxmox_vm_qemu" "k8s-lb" {
  vmid       = var.lb_vmid
  name       = "TKS-LB"
  clone      = "TKS-Debian-Template"
  full_clone = true

  target_node = var.proxmox_hostname
  pool        = var.proxmox_pool

  cores  = var.lb_vcpu
  memory = var.lb_mem

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
    backup       = true
    iothread     = true
  }

  onboot = true
  agent  = 1

  os_type      = "cloud-init"
  ipconfig0    = "ip=${var.lb_ip_address}/${var.subnet_size},gw=${var.gateway}"
  nameserver   = var.nameserver
  searchdomain = var.searchdomain

  connection {
    type        = "ssh"
    user        = "tks"
    host        = var.lb_ip_address
    private_key = file(var.ssh_key_path)
  }

  provisioner "file" {
    source      = "./files/haproxy.cfg"
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
      user        = "tks"
      host        = var.lb_ip_address
      private_key = file(var.ssh_key_path)
    }
    destination = "/etc/tks/bootstrap_lb.sh"
    content = templatefile("./templates/bootstrap_lb.sh", {
      lb_hn        = var.lb_hn
      lb_version   = var.lb_version
      searchdomain = var.searchdomain
      cp_hn_prefix = var.cp_hn_prefix
      node_num     = var.node_num
    })
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "tks"
      host        = var.lb_ip_address
      private_key = file(var.ssh_key_path)
    }
    inline = ["bash /etc/tks/bootstrap_lb.sh"]
  }
}


resource "proxmox_vm_qemu" "k8s-cp" {
  depends_on = [
    proxmox_vm_qemu.k8s-lb
  ]
  count      = var.cp_num
  vmid       = var.cp_vmid + count.index
  name       = "TKS-CP-${count.index + 1}"
  clone      = "TKS-Debian-Template"
  full_clone = true

  target_node = var.proxmox_hostname
  pool        = var.proxmox_pool

  cores  = var.cp_vcpu
  memory = var.cp_mem

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
    backup       = true
    iothread     = true
  }

  onboot = true
  agent  = 1

  os_type = "cloud-init"
  # ipconfig0    = "ip=${var.cp_ip_address}/${var.subnet_size},gw=${var.gateway}"
  # Telmate Terraform provider does not support dynamic IP Addresses with `count`.
  # As a result, the below is used as a workaround. This introduces a node limitation of 9.
  ipconfig0    = "ip=${var.ip_prefix}.${count.index + var.cp_start_ip}/${var.subnet_size},gw=${var.gateway}"
  nameserver   = var.nameserver
  searchdomain = var.searchdomain

  provisioner "file" {
    destination = "/etc/tks/bootstrap_cp.sh"
    connection {
      type        = "ssh"
      user        = "tks"
      host        = "${var.ip_prefix}.${count.index + var.cp_start_ip}"
      private_key = file(var.ssh_key_path)
    }
    content = templatefile("./templates/bootstrap_cp.sh", {
      lb_hn        = var.lb_hn
      searchdomain = var.searchdomain
      cp_hn_prefix = var.cp_hn_prefix
      count_index  = count.index
    })
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "tks"
      host        = "${var.ip_prefix}.${count.index + var.cp_start_ip}"
      private_key = file(var.ssh_key_path)
    }
    inline = ["bash /etc/tks/bootstrap_cp.sh"]
  }
}


resource "proxmox_vm_qemu" "k8s-nodes" {
  depends_on = [
    proxmox_vm_qemu.k8s-cp
  ]
  count      = var.node_num
  vmid       = var.node_vmid + count.index
  name       = "TKS-Node-${count.index + 1}"
  clone      = "TKS-Debian-Template"
  full_clone = true

  target_node = var.proxmox_hostname
  pool        = var.proxmox_pool

  cores  = var.node_vcpu
  memory = var.node_mem

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
    backup       = true
    iothread     = true
  }

  onboot = true
  agent  = 1

  os_type = "cloud-init"
  # ipconfig0    = "ip=${var.node_ip_address}/${var.subnet_size},gw=${var.gateway}"
  # Telmate Terraform provider does not support dynamic IP Addresses with `count`.
  # As a result, the below is used as a workaround. This introduces a node limitation of 9.
  ipconfig0    = "ip=${var.ip_prefix}.${count.index + var.node_start_ip}/${var.subnet_size},gw=${var.gateway}"
  nameserver   = var.nameserver
  searchdomain = var.searchdomain

  connection {
    type        = "ssh"
    user        = "tks"
    host        = "${var.ip_prefix}.${count.index + var.node_start_ip}"
    private_key = file("/Users/tj/.ssh/Sol.Milkyway/kubernetes.sol.milkyway")
  }

  provisioner "file" {
    destination = "/etc/tks/bootstrap_node.sh"
    content = templatefile("./templates/bootstrap_node.sh", {
      searchdomain   = var.searchdomain
      node_hn_prefix = var.node_hn_prefix
      count_index    = count.index
    })
  }
  provisioner "remote-exec" {
    inline = ["bash /etc/tks/bootstrap_node.sh"]
  }
}
