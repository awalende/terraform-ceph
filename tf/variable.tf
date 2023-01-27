# Overwrite these:

variable "os_flavor_id" {
  description = "The id of the flavor to use for the instances"
  default = "7a876e27-28f2-41e5-9e31-d09386d067a8"
}

variable "os_image_id" {
  description = "The id of the OpenStack-Image to use."
  default = "0e880e9c-10a2-4c17-a52b-bac4eca50745"
}

variable "os_keypair_name" {
  description = "Name of the OpenStack-Keypair used for all instances."
  default = "os-bibi"
}

variable "os_external_network_id" {
  description = "The OpenStack external network id on which the router will route out traffic"
  default = "f8f2b7e2-9113-4f3c-a072-38e87126a123"
}

variable "os_floatingip_pool" {
  description = "OpenStack floatingIP-Pool by name"
  default = "external"
}


# Standard declaration of variables for the Ceph Part
variable "mon_count" {
  description = "Count of Ceph Monitor nodes in the cluster. Needs to be (n / 2) + 1 for quorum."
  default = 3
  type = number
  validation {
    condition = var.mon_count > 0
    error_message = "Monitor node count must be larger than 0"
  }
}

variable "osd_count" {
  description = "Count of Ceph OSD nodes."
  default = 6
  type = number
  validation {
    condition = var.osd_count > 0
    error_message = "OSD node count must be larger than 0"
  }
}

variable "disk_count" {
    description = "Amount of total OSD devices, gets balanced between OSD nodes."
    default = 12
    type = number
    validation {
      condition = (var.disk_count > 1) && (var.disk_count % 2 == 0)
      error_message = "Insufficient count of osd disks specified"
    }
}

variable "disk_size" {
  description = "Disk size of each osd disk in gigabyte."
  default = 100
  type = number
  validation {
    condition = var.disk_size > 1
    error_message = "Disk needs to be at least 1 gigabyte large"
  }
}