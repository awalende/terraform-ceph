# Standard declaration of variables

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