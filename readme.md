# Terraform Provider Crusoe

This repo defines the official Terraform Provider for use with [Crusoe Cloud](https://crusoecloud.com/), the world's first carbon-reducing, low-cost GPU cloud platform.

To get started, first [install Terraform](https://developer.hashicorp.com/terraform/downloads). Then, get an access keypair from https://console.crusoecloud.ai/security/tokens and add the following to the beginning of your `.tf` file:

```
terraform {
  required_providers {
    crusoe = {
      source = "registry.terraform.io/crusoecloud/crusoe"
    }
  }
}

provider "crusoe" {
  access_key = "<my_key>"
  secret_key = "<my_secret>"
}

locals {
  ssh_key = file("~/.ssh/id_ed25519.pub")
}
```

## Examples

```terraform
# Create 10, 8xA100-80GB VMs
resource "crusoe_compute_instance" "nodes" {
  name = "node-${count.index}"
  type = "a100-80gb.8x"
  ssh_key = local.ssh_key
}
```

For more usage examples, including storage disks, startup scripts, and firewall rules, see the [examples folder](./examples/).

## Development

Add the following to your `~/.terraformrc`

```
provider_installation {

  dev_overrides {
    "registry.terraform.io/crusoecloud/crusoe" = "/Users/{MY_USERNAME_HERE}/go/bin/"
  }

  # For all other providers, install them directly from their origin provider
  # registries as normal. If you omit this, Terraform will _only_ use
  # the dev_overrides block, and so no other providers will be available.
  direct {}
}
```

Run `make install` to build a provider and install it into your go-path. Then, you should be able to run `terraform apply` with the provided examples.