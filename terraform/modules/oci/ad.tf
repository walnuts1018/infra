data "oci_identity_availability_domains" "ads" {
  compartment_id = local.tenancy_ocid
}
