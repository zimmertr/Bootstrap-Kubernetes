provider "proxmox" {
  pm_api_url      = "https://${var.PROXMOX_HOSTNAME}:${var.PROXMOX_PORT}/api2/json"
  pm_user         = var.PROXMOX_USER
  pm_password     = var.PROXMOX_PASSWORD
  pm_parallel     = var.PROXMOX_NUM_PROCESSES
  pm_tls_insecure = var.PROXMOX_ALLOW_INSECURE
  pm_timeout      = var.PROXMOX_API_TIMEOUT
}









