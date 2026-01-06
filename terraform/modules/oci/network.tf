resource "oci_core_vcn" "default" {
  cidr_block     = "172.16.0.0/16"
  is_ipv6enabled = true
  compartment_id = data.oci_identity_availability_domains.ads.compartment_id
  display_name   = "default"
  dns_label      = "default"
}

output "default_vcn_ipv6_cidr_block" {
  value = oci_core_vcn.default.ipv6cidr_blocks[0]
}

resource "oci_core_internet_gateway" "default" {
  compartment_id = data.oci_identity_availability_domains.ads.compartment_id
  display_name   = "default-internet-gateway"
  vcn_id         = oci_core_vcn.default.id
}

resource "oci_core_route_table" "default_rt" {
  compartment_id = data.oci_identity_availability_domains.ads.compartment_id
  vcn_id         = oci_core_vcn.default.id
  display_name   = "default-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.default.id
  }
}

resource "oci_core_security_list" "default_sl" {
  compartment_id = data.oci_identity_availability_domains.ads.compartment_id
  vcn_id         = oci_core_vcn.default.id
  display_name   = "default-sl"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
}

resource "oci_core_security_list" "ssh_sl" {
  compartment_id = data.oci_identity_availability_domains.ads.compartment_id
  vcn_id         = oci_core_vcn.default.id
  display_name   = "ssh-sl"

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_security_list" "wireguard_sl" {
  compartment_id = data.oci_identity_availability_domains.ads.compartment_id
  vcn_id         = oci_core_vcn.default.id
  display_name   = "wireguard-sl"

  ingress_security_rules {
    protocol = "17" # UDP
    source   = "0.0.0.0/0"
    udp_options {
      min = 51820
      max = 51820
    }
  }
}


resource "oci_core_subnet" "default_subnet" {
  cidr_block        = "172.16.0.0/24"
  ipv6cidr_block    = cidrsubnet(oci_core_vcn.default.ipv6cidr_blocks[0], 8, 1)
  compartment_id    = data.oci_identity_availability_domains.ads.compartment_id
  vcn_id            = oci_core_vcn.default.id
  display_name      = "default-subnet"
  route_table_id    = oci_core_route_table.default_rt.id
  security_list_ids = [oci_core_security_list.default_sl.id, oci_core_security_list.ssh_sl.id, oci_core_security_list.wireguard_sl.id]
}

output "default_subnet_ipv6_cidr_block" {
  value = oci_core_subnet.default_subnet.ipv6cidr_block
}
