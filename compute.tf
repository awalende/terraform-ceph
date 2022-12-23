resource "openstack_compute_instance_v2" "gateway" {
  name            = "gateway"
  image_id        = "0e880e9c-10a2-4c17-a52b-bac4eca50745"
  flavor_id       = "7a876e27-28f2-41e5-9e31-d09386d067a8"
  key_pair        = "os-bibi"
  security_groups = ["default"]

  network {
    name = openstack_networking_network_v2.my_network.name
    fixed_ip_v4 = "192.168.199.7"
  }
}

resource "openstack_compute_instance_v2" "mon" {
  name            = "mon${count.index}"
  image_id        = "0e880e9c-10a2-4c17-a52b-bac4eca50745"
  flavor_id       = "7a876e27-28f2-41e5-9e31-d09386d067a8"
  key_pair        = "os-bibi"
  security_groups = ["default"]
  count = "3"

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
  image_id        = "0e880e9c-10a2-4c17-a52b-bac4eca50745"
  flavor_id       = "8d10482f-2bc5-4394-ba98-f7dc6050a05a"
  key_pair        = "os-bibi"
  security_groups = ["default"]

  count = "6"

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