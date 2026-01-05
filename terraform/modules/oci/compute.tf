
resource "oci_core_instance" "orange" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = data.oci_identity_availability_domains.ads.compartment_id
  shape               = "VM.Standard.A1.Flex"
  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }

  source_details {
    source_id   = "ocid1.image.oc1.ap-osaka-1.aaaaaaaawzfbc5pjimseh6eisfqhfztalzx46h5bhntvxomckmulk7hqtyoa"
    source_type = "image"
  }

  display_name = "orange"
  create_vnic_details {
    assign_public_ip = true
    subnet_id        = oci_core_subnet.default_subnet.id
  }
  metadata = {
    ssh_authorized_keys = local.ssh_public_key
  }
  preserve_boot_volume = false
}

locals {
  ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFCARCw/4dlz/+tr5o45BvEeAJDYd0lA+ntdbYgiMBdn"
}

output "public-ip-for-orange-instance" {
  value = oci_core_instance.orange.public_ip
}
