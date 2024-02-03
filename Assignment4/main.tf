
## Connect with Vsphere
provider "vsphere" {
  user           = var.db_username #Change to VSphere username
  password       = var.db_password #Change to proper password
  vsphere_server = "192.168.30.140" #Change to IP address
  allow_unverified_ssl = true
}

variable "num"{
  default = 1
  type = number
}

variable "datacenter" {
  default = "Center of Data"
}

variable "hosts" {
  default = [
    "192.168.30.139",
    "192.168.30.138",
  ]
}

variable "datastore" {
  default = 1  
}

data "vsphere_datacenter" "datacenter" {
  name = var.datacenter
}

data "vsphere_host" "host" {
  count         = length(var.hosts)
  name          = var.hosts[count.index]
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

## CREATE A CLUSTER
resource "vsphere_compute_cluster" "compute_cluster" {
  name            = "HA_Cluster"
  datacenter_id   = data.vsphere_datacenter.datacenter.id
  host_system_ids = toset(data.vsphere_host.host[*].id)

  drs_enabled          = true
  drs_automation_level = "fullyAutomated"

  ha_enabled = true
  ha_heartbeat_datastore_policy = "allFeasibleDsWithUserPreference"
  ha_heartbeat_datastore_ids    = [vsphere_nas_datastore.datastore.id]
  ha_vm_component_protection = "disabled"
  force_evacuate_on_destroy = true
}

## RESOURCE POOL SECTION
resource "vsphere_resource_pool" "resource_pool" {
  name                    = "Resource_Pool_000893493"
  parent_resource_pool_id = vsphere_compute_cluster.compute_cluster.resource_pool_id
}

resource "vsphere_nas_datastore" "datastore" {
  name            = var.datacenter
  type         = "NFS"
  host_system_ids = [for host in data.vsphere_host.host : host.id]
  remote_hosts = ["192.168.30.145"]
  remote_path  = "/srv/nfsroot"
}

##VERIFY THE CREATED POOL
resource "vsphere_virtual_machine" "vm" {
  count            = var.num
  name             = "VM from Terraform"
  resource_pool_id = vsphere_compute_cluster.compute_cluster.resource_pool_id
  datastore_id     = vsphere_nas_datastore.datastore.id
  num_cpus         = 1
  memory           = 256
  guest_id         = "other3xLinux64Guest"
  wait_for_guest_net_timeout = 0
  network_interface {
    network_id = data.vsphere_network.network.id
  }
  disk {
    label = "disk0"
    size  = 1
  }
  cdrom {
    datastore_id = vsphere_nas_datastore.datastore.id
    path        = "ISO/AlpineOS.iso"
  }
}





