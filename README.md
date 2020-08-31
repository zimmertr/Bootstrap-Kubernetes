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

### Prepare Local Environment

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



### Create VM Template

1. TKS is configured to receive variables via ENV. Export the required environment variables. Optionally configure your shell to not save commands to history that start with spaces to avoid compromising secrets. Supported environment variables can be found in `./ansible/variables.yml`.
```bash
  # Ansible Configuration
  export ANSIBLE_REMOTE_USER="root"
  export ANSIBLE_PRIVATE_KEY_FILE="/Users/tj/.ssh/Sol.Milkyway/earth.sol.milkyway"

  # Template Configuration
  export TEMPLATE_VM_ID=100000
  export TEMPLATE_TKS_VLAN_ID=50
  export TEMPLATE_STORAGE_NAME="RAIDPool_Templates"
  export TEMPLATE_SSH_PUBLIC_KEY=`cat /Users/tj/.ssh/Sol.Milkyway/kubernetes.sol.milkyway.pub`
  export TEMPLATE_IP_ADDRESS="192.168.50.250"
  export TEMPLATE_GATEWAY="192.168.50.1"
  export TEMPLATE_NAMESERVER="192.168.1.100"
  export TEMPLATE_SEARCH_DOMAIN="sol.milkyway"

	# HAProxy Configuration
  export HAPROXY_HOSTNAME="tks-lb"
  export HAPROXY_STATS_ENABLE=true
  export HAPROXY_STATS_USERNAME="tks"
  export HAPROXY_STATS_PASSWORD="P@ssw0rd1\!" # Don't forget to escape your special characters.

  # Kubernetes Secrets
  export K8S_JOIN_TOKEN="abcdef.1234567890abcdef"
  export K8S_CERT_KEY="abcdef1234567890abcdef1234567890abcdef01234567890abcdef123457890"
```

2. Build a template
```bash
ansible-playbook -i inventory.yml TKS-Bootstrap_Kubernetes/Ansible/create_template.yml
```

### Deploy TKS

1. Export the required environment variables. Supported environment variables can be found in `./ansible/variables.yml`.
```bash
  export TKS_CREATE_POOL=true
  export TKS_POOL_NAME="TKS"
```

2. Deploy the Resource Pool

```bash
ansible-playbook -i inventory.yml TKS-Bootstrap_Kubernetes/Ansible/create_pool.yml
```

3. Export the required environment variables. Supported environment variables can be found in `./terraform/variables.tf`.

```bash
  # Proxmox Configuration
  export TF_VAR_PROXMOX_HOSTNAME="earth"
  export TF_VAR_PROXMOX_PASSWORD="P@ssw0rd1\!" # Don't forget to escape your special characters.

  # HAProxy VM Configuration
  export TF_VAR_HAPROXY_VMID=100
  export TF_VAR_HAPROXY_IP_ADDRESS=192.168.50.100

  # TKS VM Configuration
  export TF_VAR_TKS_VLAN_ID=$TEMPLATE_TKS_VLAN_ID
  export TF_VAR_TKS_IP_PREFIX="192.168.50"
  export TF_VAR_TKS_GATEWAY="192.168.50.1"
  export TF_VAR_TKS_NAMESERVER="192.168.1.100"
  export TF_VAR_TKS_SEARCH_DOMAIN="sol.milkyway"
  export TF_VAR_TKS_SSH_PRIVATE_KEY_PATH="/Users/tj/.ssh/Sol.Milkyway/kubernetes.sol.milkyway"
  export TF_VAR_TKS_STORAGE="FlashPool"
  export TF_VAR_TKS_STORAGE_TYPE="zfspool"
  export TF_VAR_TKS_ENABLE_BACKUPS=true
  export TF_VAR_TKS_ENABLE_ONBOOT=true
  export TF_VAR_K8S_CP_VMID=101
  export TF_VAR_K8S_CP_IP_SUFFIX=101
  export TF_VAR_K8S_CP_HOSTNAME_PREFIX="tks-cp"
  export TF_VAR_K8S_NODE_VMID=111
  export TF_VAR_K8S_NODE_IP_SUFFIX=111
  export TF_VAR_K8S_NODE_HOSTNAME_PREFIX="tks-node"
```

5. Deploy TKS to Proxmox using your configuration.
```bash
terraform init ./TKS-Bootstrap_Kubernetes/Terraform
terraform apply -auto-approve ./TKS-Bootstrap_Kubernetes/Terraform
```

