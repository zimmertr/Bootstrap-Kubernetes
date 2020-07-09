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

This repository can be used on its own but it is intended to be used as a submodule of [TKS](https://github.com/zimmertr/TKS). Consider cloning that instead. TKS enable enthusiasts and administrators alike to easily provision highly available and production-ready Kubernetes clusters on Proxmox VE. This article assumes that your environment is configured as defined by [TKS-Bootrap_Proxmox](https://github.com/zimmertr/TKS-Bootstrap_Proxmox/). 

## Instructions

### Environment Configuration

1. Clone [TKS](https://github.com/zimmertr/TKS) and modify the `inventory.yml` file according to your environment.  

   ```bash
   git clone git@github.com:zimmertr/TKS.git
   cd TKS
   vim inventory.yml
   ```

2. Configure Ansible to use the proper user and private key.

   ```bash
   export ANSIBLE_REMOTE_USER="tj"
   export ANSIBLE_PRIVATE_KEY_FILE="~/.ssh/sol.milkyway"
   ```

3. Download and install Telmate's [Terraform provider](https://github.com/Telmate/terraform-provider-proxmox) for Proxmox. 

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

### Deploy HAProxy

### Deploy Kubernetes

