mock_provider "oci" {}

variables {
  compartment_ocid = "mock-compartment"
  name             = "compatibility"
  drg_id           = "mock-drg"
  cpe_ip_address   = "203.0.113.10"
  static_routes    = ["10.40.0.0/16"]
}

run "basic_connection" {
  command = plan
  assert {
    condition     = output.cpe_name == "compatibility-cpe" && output.ipsec_name == "compatibility"
    error_message = "The connection and CPE must retain their expected names."
  }
}

run "managed_tunnel_with_identifier" {
  command = plan
  variables {
    cpe_local_identifier      = "vpn.example.test"
    cpe_local_identifier_type = "HOSTNAME"
    tunnel_managements = {
      primary = {
        tunnel_index = 0
        routing      = "BGP"
        bgp_session_info = {
          customer_bgp_asn      = 65000
          customer_interface_ip = "192.0.2.1/30"
          oracle_interface_ip   = "192.0.2.2/30"
        }
      }
    }
  }
  override_data {
    target = data.oci_core_ipsec_connection_tunnels.this
    values = {
      ip_sec_connection_tunnels = [{ id = "mock-tunnel", vpn_ip = "203.0.113.20", cpe_ip = "203.0.113.10" }]
    }
  }
  assert {
    condition     = oci_core_ipsec.this.cpe_local_identifier == "vpn.example.test" && length(oci_core_ipsec_connection_tunnel_management.this) == 1
    error_message = "The local identifier must remain on the IPSec connection and the selected tunnel must be managed."
  }
}
