# TKS-Bootstrap_Kubernetes

* [Summary](#Summary)
* [How To Use](#How-To-Use)
* [Instructions](#Instructions)
  * [Environment Configuration](#Environment-Configuration)
  * [Deploy HAProxy](#Deploy-HAProxy)
  * [Deploy Kubernetes](#Deploy-Kubernetes)

## Summary

`Bootstrap_Kubernetes`deploys a highly available Kubernetes cluster on Proxmox and configures it for immediate production use.

## How To Use

This repository can be used on its own but it is intended to be used as a submodule of [TKS](https://github.com/zimmertr/TKS). Consider cloning that instead. TKS enables enthusiasts and administrators alike to easily provision highly available and production-ready Kubernetes clusters on Proxmox VE. This article assumes that your environment is configured as defined by [TKS-Bootrap_Proxmox](https://github.com/zimmertr/TKS-Bootstrap_Proxmox/).

## Instructions

### Environment Configuration

1. Clone [TKS](https://github.com/zimmertr/TKS) and modify the `inventory.yml` file according to your environment.

   ```bash
   git clone git@github.com:zimmertr/TKS.git
   cd TKS
   vim inventory.yml
   ```

2. Download and install Telmate's [Terraform provider](https://github.com/Telmate/terraform-provider-proxmox) for Proxmox.

   ```bash
   cd /tmp
   git clone https://github.com/Telmate/terraform-provider-proxmox.git
   cd terraform-provider-proxmox

   go install github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provider-proxmox
   go install github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provisioner-proxmox
   make

   mkdir ~/.terraform.d/plugins
   cp bin/terraform-provider-proxmox ~/.terraform.d/plugins
   cp bin/terraform-provisioner-proxmox ~/.terraform.d/plugins
   rm -rf /tmp/terraform-provider-proxmox
   ```




### Deploy TKS

1. Export the required environment variables. Optionally configure your shell to not save commands to history that start with spaces to avoid compromising secrets.
```bash
  # Ansible Configuration
  export ANSIBLE_REMOTE_USER="root"
  export ANSIBLE_PRIVATE_KEY_FILE="/Users/tj/.ssh/Sol.Milkyway/earth.sol.milkyway"

  # TKS Template Configuration
  export VM_ID=100000
  export TEMPLATE_VCPUS=1
  export TEMPLATE_MEMORY=1024
  export TEMPLATE_DISK_SIZE="20G"
  export TEMPLATE_STORAGE="RAIDPool_Templates"

  export TEMPLATE_TKS_VLAN_ID=50
  export TEMPLATE_TKS_NET_BRIDGE="vmbr0"
  export TEMPLATE_IP_ADDRESS="192.168.50.250"
  export TEMPLATE_TKS_SUBNET_SIZE="24"
  export TEMPLATE_GATEWAY="192.168.50.1"
  export TEMPLATE_NAMESERVER="192.168.1.100"
  export TEMPLATE_SEARCH_DOMAIN="sol.milkyway"

  export TEMPLATE_SSH_PUBLIC_KEY=`cat /Users/tj/.ssh/Sol.Milkyway/kubernetes.sol.milkyway.pub`
```

2. Build a template
```bash
ansible-playbook -i inventory.yml TKS-Bootstrap_Kubernetes/Ansible/create_template.yml
```

3. Create a Resource Pool
```bash
  export TKS_CREATE_POOL=true
  export TKS_POOL_NAME="TKS"
ansible-playbook -i inventory.yml TKS-Bootstrap_Kubernetes/Ansible/create_pool.yml
```

4. Export the required environment variables
```bash
  # Proxmox Configuration
  export TF_VAR_PROXMOX_USER="root@pam"
  export TF_VAR_PROXMOX_PASSWORD="P@ssw0rd1!"
  export TF_VAR_PROXMOX_HOSTNAME="earth"
  export TF_VAR_PROXMOX_PORT=8006
  export TF_VAR_TKS_RESOURCE_POOL="TKS"

  # TKS VM Configuration
  export TF_VAR_cp_num=3
  export TF_VAR_cp_vmid=101
  export TF_VAR_cp_core=2
  export TF_VAR_cp_mem=10240
  export TF_VAR_cp_ip_address="192.168.50.101"

  export TF_VAR_node_num=3
  export TF_VAR_node_vmid=111
  export TF_VAR_node_core=4
  export TF_VAR_node_mem=30720
  export TF_VAR_node_ip_address="192.168.50.111"

  export TF_VAR_TKS_NET_BRIDGE="vmbr0"
  export TF_VAR_TKS_VLAN_ID=50
  #export TF_VAR_TKS_IP_PREFIX="192.168.50"
  export TF_VAR_TKS_SUBNET_SIZE=24
  export TF_VAR_GATEWAY="192.168.50.1"
  export TF_VAR_nameserver="192.168.1.100"
  export TF_VAR_searchdomain="sol.milkyway"

  export TF_VAR_storage="FlashPool"
  export TF_VAR_TKS_STORAGE_TYPE="zfspool"
  export TF_VAR_TKS_DISK_TYPE="scsi"
  export TF_VAR_TKS_DISK_SIZE=30
  export TF_VAR_ssh_key_path="/Users/tj/.ssh/Sol.Milkyway/kubernetes.sol.milkyway"
```

5. Deploy VMs
```bash
cd TKS-Bootstrap_Kubernetes/Terraform
terraform init
terraform apply -auto-approve
```

