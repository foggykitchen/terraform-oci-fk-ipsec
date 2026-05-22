variable "compartment_ocid" {
  description = "Compartment OCID where the CPE and IPSec connection will be created."
  type        = string
}

variable "name" {
  description = "Base name used for the IPSec resources."
  type        = string
}

variable "display_name" {
  description = "Optional display name override for the IPSec connection."
  type        = string
  default     = null
}

variable "drg_id" {
  description = "DRG OCID that will terminate the IPSec connection."
  type        = string
}

variable "cpe_ip_address" {
  description = "Public IP address of the remote Customer Premises Equipment."
  type        = string
}

variable "cpe_display_name" {
  description = "Optional display name override for the CPE."
  type        = string
  default     = null
}

variable "cpe_device_shape_id" {
  description = "Optional OCI CPE device shape OCID."
  type        = string
  default     = null
}

variable "cpe_local_identifier" {
  description = "Optional local identifier presented by the CPE."
  type        = string
  default     = null
}

variable "cpe_local_identifier_type" {
  description = "Optional local identifier type presented by the CPE."
  type        = string
  default     = null
}

variable "static_routes" {
  description = "Static routes advertised through the IPSec connection."
  type        = list(string)
  default     = []
}

variable "tunnel_managements" {
  description = "Optional per-tunnel management objects keyed by logical tunnel name."
  type = map(object({
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
  default = {}
}

variable "defined_tags" {
  description = "Defined tags applied to created resources."
  type        = map(string)
  default     = {}
}

variable "freeform_tags" {
  description = "Freeform tags applied to created resources."
  type        = map(string)
  default     = {}
}
