# terraform-oci-fk-ipsec

This repository contains a reusable **Terraform/OpenTofu module** for deploying **Oracle Cloud Infrastructure (OCI) IPSec connectivity primitives** such as **Customer Premises Equipment (CPE)** objects, **IPSec connections**, and optional **per-tunnel management**.

It is part of the **[FoggyKitchen.com training ecosystem](https://foggykitchen.com/courses-2/)** and serves as the OCI VPN edge building block for hybrid and multicloud connectivity patterns.

---

## 🎯 Purpose

The goal of this module is to provide a **clean, composable, and educational reference implementation** for OCI VPN edge connectivity:

- Focused on **CPE and IPSec resources**
- No hidden DRG, VCN, or subnet creation
- Designed to be composed with **terraform-oci-fk-drg** and cloud-specific VPN gateway modules

This is **not** a full landing zone replacement. It is a **connectivity edge module** intended for learning, reuse, and composition.

---

## ✨ What the module does

The module creates:

- OCI Customer Premises Equipment (CPE)
- OCI IPSec connection
- Discovered IPSec tunnel inventory
- Optional IPSec tunnel management objects

The module intentionally does **not** create:

- DRGs
- VCNs
- Subnets
- VCN route tables
- Compute instances

Each of those concerns belongs in its own dedicated module or composition layer.

---

## 📂 Repository Structure

```bash
terraform-oci-fk-ipsec/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── LICENSE
└── README.md
```

---

## 🚀 Example Usage

```hcl
module "ipsec" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-ipsec.git?ref=v0.1.1"

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

## ⚙️ Module Inputs

### Core inputs

| Variable | Type | Required | Description |
|--------|------|----------|-------------|
| `compartment_ocid` | `string` | ✅ | Compartment OCID where the CPE and IPSec connection will be created |
| `name` | `string` | ✅ | Base name used for the IPSec resources |
| `display_name` | `string` | ❌ | Optional IPSec display name override |
| `drg_id` | `string` | ✅ | Target DRG OCID |
| `cpe_ip_address` | `string` | ✅ | Public IP address of the remote CPE |
| `cpe_display_name` | `string` | ❌ | Optional CPE display name override |
| `cpe_device_shape_id` | `string` | ❌ | Optional OCI CPE device shape OCID |
| `cpe_local_identifier` | `string` | ❌ | Optional local identifier presented by the CPE |
| `cpe_local_identifier_type` | `string` | ❌ | Optional local identifier type presented by the CPE |
| `static_routes` | `list(string)` | ❌ | Static routes advertised through the IPSec connection |
| `defined_tags` | `map(string)` | ❌ | Defined tags |
| `freeform_tags` | `map(string)` | ❌ | Freeform tags |

### Tunnel management objects

| Variable | Type | Required | Description |
|--------|------|----------|-------------|
| `tunnel_managements` | `map(object)` | ❌ | Optional per-tunnel management objects keyed by logical tunnel name |

### Tunnel management object schema

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

## 📤 Outputs

| Output | Description |
|------|-------------|
| `cpe_id` | CPE OCID |
| `cpe_name` | CPE display name |
| `ipsec_id` | IPSec connection OCID |
| `ipsec_name` | IPSec connection display name |
| `tunnel_ids` | Tunnel OCIDs |
| `tunnel_vpn_ips` | OCI tunnel headend public IPs |
| `tunnel_cpe_ips` | Remote CPE public IPs as seen by OCI |
| `tunnels` | Discovered tunnel attribute map |
| `tunnel_shared_secrets` | Configured shared secrets by tunnel key |
| `tunnel_management_ids` | Tunnel management OCIDs |

---

## 🧠 Design Philosophy

- Explicit over implicit
- Small modules over monoliths
- DRG connectivity separated from IPSec edge configuration
- Optimized for **learning, reuse, and composition**

This makes the module useful for:

- OCI-to-Azure site-to-site VPN
- Hybrid IPSec foundations
- Multicloud VPN labs
- Progressive connectivity building blocks

---

## 📌 Notes

- This module focuses on OCI VPN edge primitives rather than full topologies
- DRG-side routing should remain modeled in **terraform-oci-fk-drg**
- VCN route tables should remain modeled in **terraform-oci-fk-vcn** or a composition layer

---

## 🌐 Learn More

Visit [FoggyKitchen.com](https://foggykitchen.com/) for OCI, multicloud, and Terraform/OpenTofu learning resources.

---

## 🪪 License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.  
See [LICENSE](LICENSE) for details.
