resource "openstack_compute_instance_v2" "gateway" {
  name            = "gateway"
  image_id        = var.os_image_id
  flavor_id       = var.os_flavor_id
  key_pair        = var.os_keypair_name
  security_groups = ["default"]

  network {
    name = openstack_networking_network_v2.my_network.name
    fixed_ip_v4 = "192.168.199.7"
  }
}

resource "openstack_compute_floatingip_associate_v2" "myip" {
  floating_ip = openstack_networking_floatingip_v2.gateway_floating_ip.address
  instance_id = openstack_compute_instance_v2.gateway.id
}

# Wait a little before spawning instances, network stuff needs to settle
resource "time_sleep" "wait_10_seconds" {
  create_duration = "10s"
}

resource "openstack_compute_instance_v2" "mon" {
  name            = "mon${count.index}"
  image_id        = var.os_image_id
  flavor_id       = var.os_flavor_id
  key_pair        = var.os_keypair_name
  security_groups = ["default"]
  count = var.mon_count
  depends_on = [
    time_sleep.wait_10_seconds
  ]

  network {
    name = openstack_networking_network_v2.my_network.name
    fixed_ip_v4 = "192.168.199.${count.index + 50}"
  }

  network {
    name = openstack_networking_network_v2.storage_network.name
    fixed_ip_v4 = "10.0.1.${count.index + 50}"
  }
}

resource "openstack_compute_instance_v2" "osd" {
  name            = "osd${count.index}"
  image_id        = var.os_image_id
  flavor_id       = var.os_flavor_id
  key_pair        = var.os_keypair_name
  security_groups = ["default"]
  count = var.osd_count
  depends_on = [
    time_sleep.wait_10_seconds
  ]

  network {
    name = openstack_networking_network_v2.my_network.name
    fixed_ip_v4 = "192.168.199.${count.index + 100}"
  }

  network {
    name = openstack_networking_network_v2.storage_network.name
    fixed_ip_v4 = "10.0.1.${count.index + 100}"
  }
}

# Attach Volumes to all OSD nodes
resource "openstack_compute_volume_attach_v2" "attachments" {
  count       = length(openstack_blockstorage_volume_v3.osd)
  instance_id = openstack_compute_instance_v2.osd[floor(count.index / (length(openstack_blockstorage_volume_v3.osd) / length(openstack_compute_instance_v2.osd)))].id
  volume_id   = openstack_blockstorage_volume_v3.osd[count.index].id
}