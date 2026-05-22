resource "oci_core_cpe" "this" {
  compartment_id = var.compartment_ocid
  ip_address     = var.cpe_ip_address
  display_name   = coalesce(var.cpe_display_name, "${var.name}-cpe")

  cpe_device_shape_id       = var.cpe_device_shape_id
  cpe_local_identifier      = var.cpe_local_identifier
  cpe_local_identifier_type = var.cpe_local_identifier_type

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags
}

resource "oci_core_ipsec" "this" {
  compartment_id = var.compartment_ocid
  cpe_id         = oci_core_cpe.this.id
  drg_id         = var.drg_id
  display_name   = coalesce(var.display_name, var.name)
  static_routes  = var.static_routes

  cpe_local_identifier      = var.cpe_local_identifier
  cpe_local_identifier_type = var.cpe_local_identifier_type

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags
}

data "oci_core_ipsec_connection_tunnels" "this" {
  ipsec_id = oci_core_ipsec.this.id
}

locals {
  tunnels_by_index = {
    for idx, tunnel in data.oci_core_ipsec_connection_tunnels.this.ip_sec_connection_tunnels : tostring(idx) => tunnel
  }
}

resource "oci_core_ipsec_connection_tunnel_management" "this" {
  for_each = var.tunnel_managements

  ipsec_id      = oci_core_ipsec.this.id
  tunnel_id     = local.tunnels_by_index[tostring(each.value.tunnel_index)].id
  routing       = each.value.routing
  shared_secret = try(each.value.shared_secret, null)
  ike_version   = try(each.value.ike_version, null)
  display_name  = coalesce(try(each.value.display_name, null), "${var.name}-${each.key}")

  dynamic "bgp_session_info" {
    for_each = try(each.value.bgp_session_info, null) == null ? [] : [each.value.bgp_session_info]
    content {
      customer_bgp_asn      = try(bgp_session_info.value.customer_bgp_asn, null)
      customer_interface_ip = try(bgp_session_info.value.customer_interface_ip, null)
      oracle_interface_ip   = try(bgp_session_info.value.oracle_interface_ip, null)
    }
  }

  oracle_can_initiate     = try(each.value.oracle_can_initiate, null)
  nat_translation_enabled = try(each.value.nat_translation_enabled, null)
}
