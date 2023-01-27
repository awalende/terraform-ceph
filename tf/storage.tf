resource "openstack_blockstorage_volume_v3" "osd" {
  name        = "osd-${count.index}"
  size        = 100
  count = var.disk_count
}