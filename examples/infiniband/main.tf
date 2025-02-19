terraform {
  required_providers {
    crusoe = {
      source = "registry.terraform.io/crusoecloud/crusoe"
    }
  }
}

locals {
  my_ssh_key = file("~/.ssh/id_ed25519.pub")
}

# list IB networks
data "crusoe_ib_networks" "ib_networks" {}
output "crusoe_ib" {
  value = data.crusoe_ib_networks.ib_networks
}

# create an IB partition to deploy VMs in
resource "crusoe_ib_partition" "my_partition" {
  name = "my-ib-partition"

  # available IB network IDs can be listed by using the output
  # above. alternatively, they can be obtain with the CLI by
  #   crusoe networking ib-network list
  ib_network_id = "<ib_network_id>"
}

# create two VMs, both in the same Infiniband partition
resource "crusoe_compute_instance" "my_vm1" {
  count = 8

  name = "ib-vm-${count.index}"
  type = "a100-80gb-sxm-ib.8x" # IB enabled VM type
  location = "us-east1-a" # IB currently only supported at us-east1-a
  image = "ubuntu20.04-nvidia-sxm-docker:ib-nccl2.18.3" # IB image
  ib_partition_id = crusoe_ib_partition.my_partition.id
  ssh_key = local.my_ssh_key

  disks = [
    // disk attached at startup
    crusoe_storage_disk.data_disk
  ]
}

# attached storage disk
resource "crusoe_storage_disk" "data_disk" {
  name = "data-disk"
  size = "1TiB"
  location = "us-east1-a"
}
