##################################################
# Terraform - Proxmox Provider Configuration     #
##################################################
variable "proxmox_hostname" {
  type        = string
  description = "The hostname, fully qualified domain name, or IP Address used to network with the Proxmox cluster."
}
variable "proxmox_port" {
  type        = number
  default     = 8006
  description = "The port used to network with the Proxmox API endpoint. "
}
variable "proxmox_user" {
  type        = string
  default     = "root@pam"
  description = "The user used to connect to the Proxmox API. May be required to include `@pam`."
}
variable "proxmox_password" {
  type        = string
  description = "The password for the user used to connect to the Proxmox API."
}
variable "proxmox_allow_insecure" {
  type        = bool
  default     = true
  description = "Whether or not it should be allowed for Terraform to connect to Proxmox without a trusted SSL certificate authority."
}
variable "proxmox_num_processes" {
  type        = number
  default     = 4
  description = "The number of simultaneous Proxmox actions that can occur. (EG: Creating multiple resources)"
}
variable "proxmox_api_timeout" {
  type        = number
  default     = 300
  description = "The timeout value (expressed in seconds) for Proxmox API calls."
}


##################################################
# Virtual Machine - General Configuration        #
##################################################
variable "template_name" {
  type        = string
  default     = "TKS-Debian-Template"
  description = "The name of the Proxmox template from which you want to clone the required virtual machines."
}
variable "template_username" {
  type        = string
  default     = "tks"
  description = "The name of the user with which you connect to the template."
}
variable "resource_pool" {
  type        = string
  default     = "TKS"
  description = "The Proxmox Resource Pool into which TKS will be deployed. (Must exist already)"
}
variable "enable_backups" {
  type        = bool
  default     = false
  description = "Whether or not the TKS virtual machines should automatically be backed up by proxmox."
}
variable "enable_onboot" {
  type        = bool
  default     = false
  description = "Whether or not the TKS virtual machines should automatically be started on boot by proxmox."
}


##################################################
# Virtual Machine - Network Configuration        #
##################################################
variable "net_type" {
  type        = string
  default     = "virtio"
  description = "The type of virtual network card used for the TKS virtual machines."
}
variable "net_bridge" {
  type        = string
  default     = "vmbr0"
  description = "The name of the network bridge used for the TKS virtual machines."
}
variable "vlan_id" {
  type        = number
  default     = null
  description = "If configured, the VLAN ID that is associated with the network card for the TKS virtual machines."
}
variable "ip_prefix" {
  type        = string
  description = "The first three octets of the IP Address associated with each TKS virtual machine. An initial fourth octet is configured for the Control Planes and Nodes."
}
variable "subnet_size" {
  type        = number
  default     = 24
  description = "The subnet size expressed in bits for the TKS virtual machines."
}
variable "gateway" {
  type        = string
  description = "The network gateway that should be configured for the TKS virtual machines."
}
variable "nameserver" {
  type        = string
  default     = "8.8.8.8"
  description = "The DNS server that should be configured for the TKS virtual machines."
}
variable "search_domain" {
  type        = string
  default     = null
  description = "The DNS search domain that should be configured for the TKS virtual machines."
}
variable "ssh_private_key_path" {
  type        = string
  description = "The path of the local filesystem for an SSH Private Key that will be used to authenticate against the TKS virtual machines."
}


##################################################
# Virtual Machine Storage Configuration          #
##################################################
variable "storage" {
  type        = string
  description = "The name of the storage in Proxmox onto which the TKS virtual machines should be deployed."
}
variable "storage_type" {
  type        = string
  description = "The type of the storage onto which Terraform will be deploying the TKS virtual machines."
}
variable "disk_type" {
  type        = string
  default     = "scsi"
  description = "The type of virtual hard disk that will be attached to the TKS virtual machines."
}
variable "disk_size" {
  type        = number
  default     = 30
  description = "The size, expressed in gigabytes, of the virtual hard disk that will be attached to the TKS virtual machines."
}


##################################################
# HAProxy Configuration                          #
##################################################
variable "haproxy_vmid" {
  type        = number
  default     = null
  description = "The VM ID to associate with the HAProxy virtual machine."
}
variable "haproxy_full_clone" {
  type        = bool
  default     = true
  description = "Whether or not the HAProxy virtual machine should be a full clone."
}
variable "haproxy_sockets" {
  type        = number
  default     = 1
  description = "The number of CPU sockets to add to the HAproxy virtual machine."

}
variable "haproxy_cores" {
  type        = number
  default     = 2
  description = "The number of CPU cores to add to the HAProxy virtual machine."
}
variable "haproxy_memory" {
  type        = number
  default     = 2048
  description = "The amount of memory, expressed in megabytes, to add to the HAProxy virtual machine."
}
variable "haproxy_ip_address" {
  type        = string
  description = "The IP Address to associate with the HAProxy virtual machine."
}
variable "haproxy_hostname" {
  type        = string
  default     = "tks-lb"
  description = "The name and network hostname to associate with the HAProxy virtual machine. (Search Domain is configured separately)"
}
variable "haproxy_version" {
  type        = string
  default     = "2.2.2"
  description = "The version of HAProxy to use for TKS."
}


##################################################
# Kubernetes Control Plane Configuration         #
##################################################
variable "k8s_cp_num" {
  type        = number
  default     = 3
  description = "The amount of Kubernetes control plane virtual machines to deploy for TKS."
}
variable "k8s_cp_vmid" {
  type        = number
  default     = null
  description = "The VM ID to associate with the first control plane virtual machine. Incremented by one for each node."
}
variable "k8s_cp_full_clone" {
  type        = bool
  default     = true
  description = "Whether or not the control plane virtual machines should be a full clones."
}
variable "k8s_cp_sockets" {
  type        = number
  default     = 1
  description = "The number of CPU sockets to add to each control plane virtual machine."
}
variable "k8s_cp_cores" {
  type        = number
  default     = 2
  description = "The number of CPU cores to add to each control plane virtual machine."
}
variable "k8s_cp_memory" {
  type        = number
  default     = 10240
  description = "The amount of memory, expressed in megabytes, to add to each control plane virtual machine."
}
variable "k8s_cp_ip_suffix" {
  type        = number
  description = "The last octet that, when combined with `ip_prefix`, is the IP Address of the first control plane virtual machine. Incremeneted by one for each node."
}
variable "k8s_cp_hostname_prefix" {
  type        = string
  default     = "tks-cp"
  description = "The prefix for the name and network hostname for each control plane virtual machine. ('-#' is appended to each node)"
}


##################################################
# Kubernetes Worker Node Configuration           #
##################################################
variable "k8s_node_num" {
  type        = number
  default     = 3
  description = "The amount of Kubernetes worker node virtual machines to deploy for TKS."
}
variable "k8s_node_vmid" {
  type        = number
  default     = null
  description = "The VM ID to associate with the first worker node virtual machine. Incremented by one for each node."
}
variable "k8s_node_full_clone" {
  type        = bool
  default     = true
  description = "Whether or not the worker node virtual machines should be a full clones."
}
variable "k8s_node_sockets" {
  type        = number
  default     = 1
  description = "The number of CPU sockets to add to each worker node virtual machine."
}
variable "k8s_node_cores" {
  type        = number
  default     = 4
  description = "The number of CPU cores to add to each worker node virtual machine."
}
variable "k8s_node_memory" {
  type        = number
  default     = 30720
  description = "The amount of memory, expressed in megabytes, to add to each worker node virtual machine."
}
variable "k8s_node_ip_suffix" {
  type        = string
  description = "The last octet that, when combined with `ip_prefix`, is the IP Address of the first worker node virtual machine. Incremeneted by one for each node."
}
variable "k8s_node_hostname_prefix" {
  type        = string
  default     = "tks-node"
  description = "The prefix for the name and network hostname for each worker node virtual machine. ('-#' is appended to each node)"
}
