##################################################
# Terraform - Proxmox Provider Configuration     #
##################################################
variable "PROXMOX_HOSTNAME" {
  type        = string
  description = "The hostname, fully qualified domain name, or IP Address used to network with the Proxmox cluster."
}
variable "PROXMOX_PORT" {
  type        = number
  default     = 8006
  description = "The port used to network with the Proxmox API endpoint. "
}
variable "PROXMOX_USER" {
  type        = string
  default     = "root@pam"
  description = "The user used to connect to the Proxmox API. May be required to include `@pam`."
}
variable "PROXMOX_PASSWORD" {
  type        = string
  description = "The password for the user used to connect to the Proxmox API."
}
variable "PROXMOX_ALLOW_INSECURE" {
  type        = bool
  default     = true
  description = "Whether or not it should be allowed for Terraform to connect to Proxmox without a trusted SSL certificate authority."
}
variable "PROXMOX_NUM_PROCESSES" {
  type        = number
  default     = 4
  description = "The number of simultaneous Proxmox actions that can occur. (EG: Creating multiple resources)"
}
variable "PROXMOX_API_TIMEOUT" {
  type        = number
  default     = 300
  description = "The timeout value (expressed in seconds) for Proxmox API calls."
}


##################################################
# Virtual Machine - General Configuration        #
##################################################
variable "TKS_TEMPLATE_NAME" {
  type        = string
  default     = "TKS-Debian-Template"
  description = "The name of the Proxmox template from which you want to clone the required virtual machines."
}
variable "TKS_TEMPLATE_USERNAME" {
  type        = string
  default     = "tks"
  description = "The name of the user with which you connect to the template."
}
variable "TKS_RESOURCE_POOL" {
  type        = string
  default     = "TKS"
  description = "The Proxmox Resource Pool into which TKS will be deployed. (Must exist already)"
}
variable "TKS_ENABLE_BACKUPS" {
  type        = bool
  default     = false
  description = "Whether or not the TKS virtual machines should automatically be backed up by proxmox."
}
variable "TKS_ENABLE_ONBOOT" {
  type        = bool
  default     = false
  description = "Whether or not the TKS virtual machines should automatically be started on boot by proxmox."
}


##################################################
# Virtual Machine - Network Configuration        #
##################################################
variable "TKS_NET_TYPE" {
  type        = string
  default     = "virtio"
  description = "The type of virtual network card used for the TKS virtual machines."
}
variable "TKS_NET_BRIDGE" {
  type        = string
  default     = "vmbr0"
  description = "The name of the network bridge used for the TKS virtual machines."
}
variable "TKS_VLAN_ID" {
  type        = number
  default     = null
  description = "If configured, the VLAN ID that is associated with the network card for the TKS virtual machines."
}
variable "TKS_IP_PREFIX" {
  type        = string
  description = "The first three octets of the IP Address associated with each TKS virtual machine. An initial fourth octet is configured for the Control Planes and Nodes."
}
variable "TKS_SUBNET_SIZE" {
  type        = number
  default     = 24
  description = "The subnet size expressed in bits for the TKS virtual machines."
}
variable "TKS_GATEWAY" {
  type        = string
  description = "The network gateway that should be configured for the TKS virtual machines."
}
variable "TKS_NAMESERVER" {
  type        = string
  default     = "8.8.8.8"
  description = "The DNS server that should be configured for the TKS virtual machines."
}
variable "TKS_SEARCH_DOMAIN" {
  type        = string
  default     = null
  description = "The DNS search domain that should be configured for the TKS virtual machines."
}
variable "TKS_SSH_PRIVATE_KEY_PATH" {
  type        = string
  description = "The path of the local filesystem for an SSH Private Key that will be used to authenticate against the TKS virtual machines."
}


##################################################
# Virtual Machine Storage Configuration          #
##################################################
variable "TKS_STORAGE" {
  type        = string
  description = "The name of the storage in Proxmox onto which the TKS virtual machines should be deployed."
}
variable "TKS_STORAGE_TYPE" {
  type        = string
  description = "The type of the storage onto which Terraform will be deploying the TKS virtual machines."
}
variable "TKS_DISK_TYPE" {
  type        = string
  default     = "scsi"
  description = "The type of virtual hard disk that will be attached to the TKS virtual machines."
}
variable "TKS_DISK_SIZE" {
  type        = number
  default     = 30
  description = "The size, expressed in gigabytes, of the virtual hard disk that will be attached to the TKS virtual machines."
}


##################################################
# HAProxy Configuration                          #
##################################################
variable "HAPROXY_VMID" {
  type        = number
  default     = null
  description = "The VM ID to associate with the HAProxy virtual machine."
}
variable "HAPROXY_FULL_CLONE" {
  type        = bool
  default     = true
  description = "Whether or not the HAProxy virtual machine should be a full clone."
}
variable "HAPROXY_SOCKETS" {
  type        = number
  default     = 1
  description = "The number of CPU sockets to add to the HAproxy virtual machine."

}
variable "HAPROXY_CORES" {
  type        = number
  default     = 2
  description = "The number of CPU cores to add to the HAProxy virtual machine."
}
variable "HAPROXY_MEMORY" {
  type        = number
  default     = 2048
  description = "The amount of memory, expressed in megabytes, to add to the HAProxy virtual machine."
}
variable "HAPROXY_IP_ADDRESS" {
  type        = string
  description = "The IP Address to associate with the HAProxy virtual machine."
}
variable "HAPROXY_HOSTNAME" {
  type        = string
  default     = "tks-lb"
  description = "The name and network hostname to associate with the HAProxy virtual machine. (Search Domain is configured separately)"
}
variable "HAPROXY_VERSION" {
  type        = string
  default     = "2.2.2"
  description = "The HAProxy Docker container tag to use for TKS."
}


##################################################
# Kubernetes Control Plane Configuration         #
##################################################
variable "K8S_CP_NUM" {
  type        = number
  default     = 3
  description = "The amount of Kubernetes control plane virtual machines to deploy for TKS."
}
variable "K8S_CP_VMID" {
  type        = number
  default     = null
  description = "The VM ID to associate with the first control plane virtual machine. Incremented by one for each node."
}
variable "K8S_CP_FULL_CLONE" {
  type        = bool
  default     = true
  description = "Whether or not the control plane virtual machines should be a full clones."
}
variable "K8S_CP_SOCKETS" {
  type        = number
  default     = 1
  description = "The number of CPU sockets to add to each control plane virtual machine."
}
variable "K8S_CP_CORES" {
  type        = number
  default     = 2
  description = "The number of CPU cores to add to each control plane virtual machine."
}
variable "K8S_CP_MEMORY" {
  type        = number
  default     = 10240
  description = "The amount of memory, expressed in megabytes, to add to each control plane virtual machine."
}
variable "K8S_CP_IP_SUFFIX" {
  type        = number
  description = "The last octet that, when combined with `TKS_IP_PREFIX`, is the IP Address of the first control plane virtual machine. Incremeneted by one for each node."
}
variable "K8S_CP_HOSTNAME_PREFIX" {
  type        = string
  default     = "tks-cp"
  description = "The prefix for the name and network hostname for each control plane virtual machine. ('-#' is appended to each node)"
}


##################################################
# Kubernetes Worker Node Configuration           #
##################################################
variable "K8S_NODE_NUM" {
  type        = number
  default     = 3
  description = "The amount of Kubernetes worker node virtual machines to deploy for TKS."
}
variable "K8S_NODE_VMID" {
  type        = number
  default     = null
  description = "The VM ID to associate with the first worker node virtual machine. Incremented by one for each node."
}
variable "K8S_NODE_FULL_CLONE" {
  type        = bool
  default     = true
  description = "Whether or not the worker node virtual machines should be a full clones."
}
variable "K8S_NODE_SOCKETS" {
  type        = number
  default     = 1
  description = "The number of CPU sockets to add to each worker node virtual machine."
}
variable "K8S_NODE_CORES" {
  type        = number
  default     = 4
  description = "The number of CPU cores to add to each worker node virtual machine."
}
variable "K8S_NODE_MEMORY" {
  type        = number
  default     = 30720
  description = "The amount of memory, expressed in megabytes, to add to each worker node virtual machine."
}
variable "K8S_NODE_IP_SUFFIX" {
  type        = string
  description = "The last octet that, when combined with `TKS_IP_PREFIX`, is the IP Address of the first worker node virtual machine. Incremeneted by one for each node."
}
variable "K8S_NODE_HOSTNAME_PREFIX" {
  type        = string
  default     = "tks-node"
  description = "The prefix for the name and network hostname for each worker node virtual machine. ('-#' is appended to each node)"
}
