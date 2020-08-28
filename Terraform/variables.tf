variable "proxmox_hostname" {
  type = string
}
variable "proxmox_port" {
  type    = number
  default = 8006
}
variable "proxmox_user" {
  type    = string
  default = "root@pam"
}
variable "proxmox_password" {
  type = string
}
variable "proxmox_pool" {
  type    = string
  default = "TKS"
}


variable "net_type" {
  type    = string
  default = "virtio"
}
variable "net_bridge" {
  type    = string
  default = "vmbr0"
}
variable "vlan_id" {
  type = number
}
variable "ip_prefix" {
  type = string
}
variable "subnet_size" {
  type    = string
  default = "24"
}
variable "gateway" {
  type = string
}
variable "nameserver" {
  type    = string
  default = "8.8.8.8"
}
variable "searchdomain" {
  type = string
}
variable "ssh_key_path" {
  type = string
}


variable "storage" {
  type = string
}
variable "storage_type" {
  type = string
}
variable "disk_type" {
  type    = string
  default = "scsi"
}
variable "disk_size" {
  type    = number
  default = 30
}


variable "lb_vmid" {
  type    = number
  default = 100
}
variable "lb_vcpu" {
  type    = number
  default = 2
}
variable "lb_mem" {
  type    = number
  default = 2048
}
variable "lb_ip_address" {
  type    = string
  default = "192.168.50.100"
}
variable "lb_hn" {
  type    = string
  default = "tks-lb"
}
variable "lb_version" {
  type    = string
  default = "2.2.2"
}


variable "cp_num" {
  type    = number
  default = 3
}
variable "cp_vmid" {
  type    = number
  default = 101
}
variable "cp_vcpu" {
  type    = number
  default = 2
}
variable "cp_mem" {
  type    = number
  default = 10240
}
variable "cp_start_ip" {
  type = string
}
variable "cp_hn_prefix" {
  type    = string
  default = "tks-cp"
}


variable "node_num" {
  type    = number
  default = 3
}
variable "node_vmid" {
  type    = number
  default = 111
}
variable "node_vcpu" {
  type    = number
  default = 4
}
variable "node_mem" {
  type    = number
  default = 30720
}
variable "node_start_ip" {
  type = string
}
variable "node_hn_prefix" {
  type    = string
  default = "tks-node"
}
