
resource "openstack_networking_network_v2" "my_network" {
  name           = "my_network"
  admin_state_up = "true"
}

resource "openstack_networking_network_v2" "storage_network" {
  name           = "storage_network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "management_subnet" {
  name       = "management_subnet"
  network_id = openstack_networking_network_v2.my_network.id
  cidr       = "192.168.199.0/24"
  ip_version = 4
}

resource "openstack_networking_subnet_v2" "storage_subnet" {
  name       = "storage_subnet"
  network_id = openstack_networking_network_v2.storage_network.id
  cidr       = "10.0.1.0/24"
  ip_version = 4
}

resource "openstack_compute_secgroup_v2" "secgroup_management" {
  name        = "secgroup_management"
  description = "a security group"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_networking_router_v2" "main_router" {
  name                = "main_router"
  external_network_id = "f8f2b7e2-9113-4f3c-a072-38e87126a123"
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.main_router.id
  subnet_id = openstack_networking_subnet_v2.management_subnet.id
}


resource "openstack_networking_floatingip_v2" "gateway_floating_ip" {
  pool = "external"
}