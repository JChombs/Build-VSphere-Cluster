provider "vsphere" {
  user           = "administrator@Chambers.local" # Change to VSphere username
  password       = "Glovefood1231!" # Change to proper password
  vsphere_server = "192.168.30.140" # Change to IP address
  allow_unverified_ssl = true
}

variable "datacenter" {
  default = "Center of Data"
}

variable "hosts" {
  default = [
    "192.168.30.137",
    "192.168.30.138",
  ]
}

data "vsphere_datacenter" "datacenter" {
  name = var.datacenter
}

data "vsphere_host" "host" {
  count         = length(var.hosts)
  name          = var.hosts[count.index]
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "compute_cluster" {
  name          = "HA Cluster"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_distributed_virtual_switch" "dvswitch" {
  name          = "NFS" # Change to the name of your distributed switch
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_datastore" "nfs_datastore" {
  name     = "localhost"
  type     = "NFS"
  remote_host = "192.168.30.145"
  remote_path = "/srv/nfsroot"
  access_mode = "readWrite"  # Adjust as needed (read-only or readWrite)
  folder    = data.vsphere_datacenter.dc.id
  cluster_id = data.vsphere_compute_cluster.compute_cluster.id
}


