output "cpe_id" {
  description = "CPE OCID."
  value       = oci_core_cpe.this.id
}

output "cpe_name" {
  description = "CPE display name."
  value       = oci_core_cpe.this.display_name
}

output "ipsec_id" {
  description = "IPSec connection OCID."
  value       = oci_core_ipsec.this.id
}

output "ipsec_name" {
  description = "IPSec connection display name."
  value       = oci_core_ipsec.this.display_name
}

output "tunnel_ids" {
  description = "List of IPSec tunnel OCIDs."
  value       = [for tunnel in data.oci_core_ipsec_connection_tunnels.this.ip_sec_connection_tunnels : tunnel.id]
}

output "tunnel_vpn_ips" {
  description = "List of OCI tunnel headend public IPs."
  value       = [for tunnel in data.oci_core_ipsec_connection_tunnels.this.ip_sec_connection_tunnels : tunnel.vpn_ip]
}

output "tunnel_cpe_ips" {
  description = "List of remote CPE public IPs as seen by OCI tunnels."
  value       = [for tunnel in data.oci_core_ipsec_connection_tunnels.this.ip_sec_connection_tunnels : tunnel.cpe_ip]
}

output "tunnels" {
  description = "Map of tunnel index to discovered tunnel attributes."
  value = {
    for idx, tunnel in data.oci_core_ipsec_connection_tunnels.this.ip_sec_connection_tunnels : tostring(idx) => {
      id      = tunnel.id
      cpe_ip  = tunnel.cpe_ip
      vpn_ip  = tunnel.vpn_ip
      status  = try(tunnel.status, null)
      routing = try(tunnel.routing, null)
    }
  }
}

output "tunnel_shared_secrets" {
  description = "Map of managed tunnel keys to configured shared secrets."
  value = {
    for key, management in var.tunnel_managements : key => try(management.shared_secret, null)
  }
  sensitive = true
}

output "tunnel_management_ids" {
  description = "Map of tunnel management keys to OCIDs."
  value = {
    for key, management in oci_core_ipsec_connection_tunnel_management.this : key => management.id
  }
}
