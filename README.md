# terraform-oci-fk-ipsec

This repository contains a reusable **Terraform / OpenTofu module** for deploying an **OCI IPSec connection** with its **Customer Premises Equipment (CPE)** object and optional **per-tunnel management**.

---

## Purpose

The module is designed for composable OCI hybrid and multicloud VPN patterns where:

- the DRG is created in a separate reusable module
- the remote CPE is modeled explicitly
- static-route or tunnel-management settings must be controlled by Terraform

It is intended to compose cleanly with `terraform-oci-fk-drg` and cloud-specific VPN gateway modules.

---

## What the module does

The module creates:

- one `oci_core_cpe`
- one `oci_core_ipsec`
- discovered IPSec tunnel inventory through `oci_core_ipsec_connection_tunnels`
- optional `oci_core_ipsec_connection_tunnel_management` objects

The module intentionally does **not** create:

- DRGs
- VCNs
- Subnets
- VCN route tables

Those resources should be composed separately.

---

## Example Usage

```hcl
module "ipsec" {
  source = "git::https://github.com/mlinxfeld/terraform-oci-fk-ipsec.git?ref=v0.1.0"

  compartment_ocid = var.compartment_ocid
  name             = "ipsec-fk-demo"
  drg_id           = module.drg.drg_id
  cpe_ip_address   = module.azure_public_ip.ip_address
  static_routes    = ["10.40.0.0/16"]

  tunnel_managements = {
    tunnel1 = {
      tunnel_index  = 0
      routing       = "STATIC"
      shared_secret = "FoggyKitchenDemoSecret01!"
    }
    tunnel2 = {
      tunnel_index  = 1
      routing       = "STATIC"
      shared_secret = "FoggyKitchenDemoSecret02!"
    }
  }
}
```

---

## Inputs

| Variable | Required | Description |
|------|------|-------------|
| `compartment_ocid` | ✅ | Compartment OCID |
| `name` | ✅ | Base name for IPSec resources |
| `display_name` | ❌ | Optional IPSec display name override |
| `drg_id` | ✅ | Target DRG OCID |
| `cpe_ip_address` | ✅ | Remote CPE public IP address |
| `cpe_display_name` | ❌ | Optional CPE display name override |
| `cpe_device_shape_id` | ❌ | Optional CPE device shape OCID |
| `cpe_local_identifier` | ❌ | Optional CPE local identifier |
| `cpe_local_identifier_type` | ❌ | Optional CPE local identifier type |
| `static_routes` | ❌ | Static routes for the IPSec connection |
| `tunnel_managements` | ❌ | Optional per-tunnel management objects |
| `defined_tags` | ❌ | Defined tags |
| `freeform_tags` | ❌ | Freeform tags |

### Tunnel management schema

```hcl
tunnel_managements = map(object({
  tunnel_index            = number
  display_name            = optional(string)
  routing                 = optional(string, "STATIC")
  ike_version             = optional(string)
  shared_secret           = optional(string)
  oracle_can_initiate     = optional(string)
  nat_translation_enabled = optional(string)
  bgp_session_info = optional(object({
    customer_bgp_asn      = optional(number)
    customer_interface_ip = optional(string)
    oracle_interface_ip   = optional(string)
  }))
}))
```

---

## Outputs

| Output | Description |
|------|-------------|
| `cpe_id` | CPE OCID |
| `cpe_name` | CPE display name |
| `ipsec_id` | IPSec connection OCID |
| `ipsec_name` | IPSec connection display name |
| `tunnel_ids` | Tunnel OCIDs |
| `tunnel_vpn_ips` | OCI tunnel headend public IPs |
| `tunnel_cpe_ips` | Remote CPE public IPs seen by OCI |
| `tunnels` | Discovered tunnel attribute map |
| `tunnel_shared_secrets` | Configured shared secrets by tunnel key |
| `tunnel_management_ids` | Tunnel management OCIDs |

---

## License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.
