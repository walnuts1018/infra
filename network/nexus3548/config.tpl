version {{ op://Network/nexus3548/software_version }}
hostname switch

no feature telnet
feature lacp
feature lldp

no password strength-check
username admin password 5 {{ op://Network/nexus3548/admin_password_hash }}  role network-admin
username admin sshkey ssh-rsa {{ op://Network/nexus3548/admin_ssh_public_key }}
ip domain-lookup
service unsupported-transceiver
ip access-list copp-system-acl-bfd
  10 permit udp any any eq 3784
  20 permit udp any any eq 3785
ip access-list copp-system-acl-eigrp
  10 permit eigrp any any
ip access-list copp-system-acl-ftp
  10 permit tcp any any eq ftp-data
  20 permit tcp any any eq ftp
  30 permit tcp any eq ftp-data any
  40 permit tcp any eq ftp any
ip access-list copp-system-acl-http
  10 permit tcp any any eq www
  20 permit tcp any any eq 443
ip access-list copp-system-acl-icmp
  10 permit icmp any any
ip access-list copp-system-acl-ntp
  10 permit udp any any eq ntp
  20 permit udp any eq ntp any
ip access-list copp-system-acl-ping
  10 permit icmp any any echo
  20 permit icmp any any echo-reply
ip access-list copp-system-acl-routingproto1
  10 permit tcp any any eq bgp
  20 permit tcp any eq bgp any
  30 permit tcp any any eq 639
  40 permit tcp any eq 639 any
  50 permit ospf any any
ip access-list copp-system-acl-routingproto2
  10 permit 112 any 224.0.0.0/24
ip access-list copp-system-acl-ssh
  10 permit tcp any any eq 22
  20 permit tcp any eq 22 any
ip access-list copp-system-acl-stftp
  10 permit udp any any eq tftp
  20 permit udp any any eq 1758
  30 permit udp any eq tftp any
  40 permit udp any eq 1758 any
  50 permit tcp any any eq 115
  60 permit tcp any eq 115 any
ip access-list copp-system-acl-tacacsradius
  10 permit tcp any any eq tacacs
  20 permit tcp any eq tacacs any
  30 permit udp any any eq 1812
  40 permit udp any any eq 1813
  50 permit udp any any eq 1645
  60 permit udp any any eq 1646
  70 permit udp any eq 1812 any
  80 permit udp any eq 1813 any
  90 permit udp any eq 1645 any
  100 permit udp any eq 1646 any
ip access-list copp-system-acl-telnet
  10 permit tcp any any eq telnet
  20 permit tcp any any eq 107
  30 permit tcp any eq telnet any
  40 permit tcp any eq 107 any
ip access-list copp-system-dhcp-relay
  10 permit udp any eq bootps any eq bootps
class-map type control-plane match-any copp-ftp
  match access-group name copp-system-acl-ftp
class-map type control-plane match-any copp-http
  match access-group name copp-system-acl-http
class-map type control-plane match-any copp-icmp
  match access-group name copp-system-acl-icmp
class-map type control-plane match-any copp-ntp
  match access-group name copp-system-acl-ntp
class-map type control-plane match-any copp-s-arp
class-map type control-plane match-any copp-s-bfd
  match access-group name copp-system-acl-bfd
class-map type control-plane match-any copp-s-bpdu
class-map type control-plane match-any copp-s-cdp
class-map type control-plane match-any copp-s-default
class-map type control-plane match-any copp-s-dhcpreq
class-map type control-plane match-any copp-s-dhcpresp
  match access-group name copp-system-dhcp-relay
class-map type control-plane match-any copp-s-dpss
class-map type control-plane match-any copp-s-eigrp
  match access-group name copp-system-acl-eigrp
class-map type control-plane match-any copp-s-glean
class-map type control-plane match-any copp-s-igmp
class-map type control-plane match-any copp-s-ip-nat
class-map type control-plane match-any copp-s-ip-options
class-map type control-plane match-any copp-s-ipmc-g-hit
class-map type control-plane match-any copp-s-ipmc-rpf-fail-g
class-map type control-plane match-any copp-s-ipmc-rpf-fail-sg
class-map type control-plane match-any copp-s-ipmcmiss
class-map type control-plane match-any copp-s-l3destmiss
class-map type control-plane match-any copp-s-l3mtufail
class-map type control-plane match-any copp-s-lacp
class-map type control-plane match-any copp-s-lldp
class-map type control-plane match-any copp-s-pimautorp
class-map type control-plane match-any copp-s-pimreg
class-map type control-plane match-any copp-s-ping
  match access-group name copp-system-acl-ping
class-map type control-plane match-any copp-s-ptp
class-map type control-plane match-any copp-s-routingProto1
  match access-group name copp-system-acl-routingproto1
class-map type control-plane match-any copp-s-routingProto2
  match access-group name copp-system-acl-routingproto2
class-map type control-plane match-any copp-s-ttl1
class-map type control-plane match-any copp-snmp
class-map type control-plane match-any copp-ssh
  match access-group name copp-system-acl-ssh
class-map type control-plane match-any copp-stftp
  match access-group name copp-system-acl-stftp
class-map type control-plane match-any copp-tacacsradius
  match access-group name copp-system-acl-tacacsradius
class-map type control-plane match-any copp-telnet
  match access-group name copp-system-acl-telnet
policy-map type control-plane copp-system-policy
  class copp-s-default
    police pps 400
  class copp-s-ping
    police pps 100
  class copp-s-l3destmiss
    police pps 100
  class copp-s-glean
    police pps 500
  class copp-s-l3mtufail
    police pps 100
  class copp-s-ttl1
    police pps 100
  class copp-s-ip-options
    police pps 100
  class copp-s-ip-nat
    police pps 100
  class copp-s-ipmcmiss
    police pps 400
  class copp-s-ipmc-g-hit
    police pps 400
  class copp-s-ipmc-rpf-fail-g
    police pps 400
  class copp-s-ipmc-rpf-fail-sg
    police pps 400
  class copp-s-dhcpreq
    police pps 300
  class copp-s-dhcpresp
    police pps 300
  class copp-s-igmp
    police pps 400
  class copp-s-routingProto2
    police pps 1300
  class copp-s-eigrp
    police pps 200
  class copp-s-pimreg
    police pps 200
  class copp-s-pimautorp
    police pps 200
  class copp-s-routingProto1
    police pps 1000
  class copp-s-arp
    police pps 200
  class copp-s-ptp
    police pps 1000
  class copp-s-bfd
    police pps 350
  class copp-s-bpdu
    police pps 12000
  class copp-s-dpss
    police pps 6400
  class copp-s-cdp
    police pps 400
  class copp-s-lacp
    police pps 400
  class copp-s-lldp
    police pps 500
  class copp-icmp
    police pps 200
  class copp-telnet
    police pps 500
  class copp-ssh
    police pps 500
  class copp-snmp
    police pps 500
  class copp-ntp
    police pps 100
  class copp-tacacsradius
    police pps 400
  class copp-stftp
    police pps 400
  class copp-ftp
    police pps 100
  class copp-http
    police pps 100
control-plane
  service-policy input copp-system-policy
ntp server {{ op://Network/nexus3548/ntp_server }} use-vrf management

vlan configuration 20
vlan 1
vlan 10
  name Management
vlan 20
  name WAN
vlan 100
  name server
vlan 200
  name user
vlan 250
  name ix2215-map-e-ipv4-transit
vlan 251
  name ix2215-map-e-ipv6-transit
vrf context management
  ip route 0.0.0.0/0 192.168.4.1

interface port-channel1
  speed 1000
  description almond
  switchport mode trunk
  switchport trunk allowed vlan 10,20,100,200,250-251

interface Ethernet1/1
  description vanilla
  switchport mode trunk
  switchport trunk allowed vlan 10,20,100,200,250-251
  spanning-tree port type edge trunk
  no shutdown

interface Ethernet1/2
  shutdown

interface Ethernet1/3
  shutdown

interface Ethernet1/4
  shutdown

interface Ethernet1/5
  shutdown

interface Ethernet1/6
  shutdown

interface Ethernet1/7
  shutdown

interface Ethernet1/8
  shutdown

interface Ethernet1/9
  shutdown

interface Ethernet1/10
  shutdown

interface Ethernet1/11
  shutdown

interface Ethernet1/12
  shutdown

interface Ethernet1/13
  shutdown

interface Ethernet1/14
  shutdown

interface Ethernet1/15
  shutdown

interface Ethernet1/16
  shutdown

interface Ethernet1/17
  speed 1000
  description almond
  switchport mode trunk
  switchport trunk allowed vlan 10,20,100,200,250-251
  channel-group 1 mode active
  no shutdown

interface Ethernet1/18
  speed 1000
  description almond
  switchport mode trunk
  switchport trunk allowed vlan 10,20,100,200,250-251
  channel-group 1 mode active
  no shutdown

interface Ethernet1/19
  shutdown

interface Ethernet1/20
  shutdown

interface Ethernet1/21
  shutdown

interface Ethernet1/22
  shutdown

interface Ethernet1/23
  shutdown

interface Ethernet1/24
  shutdown

interface Ethernet1/25
  shutdown

interface Ethernet1/26
  shutdown

interface Ethernet1/27
  shutdown

interface Ethernet1/28
  shutdown

interface Ethernet1/29
  shutdown

interface Ethernet1/30
  shutdown

interface Ethernet1/31
  shutdown

interface Ethernet1/32
  shutdown

interface Ethernet1/33
  shutdown

interface Ethernet1/34
  shutdown

interface Ethernet1/35
  shutdown

interface Ethernet1/36
  shutdown

interface Ethernet1/37
  shutdown

interface Ethernet1/38
  shutdown

interface Ethernet1/39
  shutdown

interface Ethernet1/40
  shutdown

interface Ethernet1/41
  shutdown

interface Ethernet1/42
  shutdown

interface Ethernet1/43
  shutdown

interface Ethernet1/44
  shutdown

interface Ethernet1/45
  shutdown

interface Ethernet1/46
  shutdown

interface Ethernet1/47
  shutdown

interface Ethernet1/48
  no lldp transmit
  no lldp receive
  description ONU
  switchport access vlan 20
  no cdp enable
  spanning-tree port type edge
  spanning-tree bpdufilter enable
  no shutdown

interface mgmt0
  description OOB_Management_to_Aruba_VLAN10
  vrf member management
  ip address 192.168.4.2/24
clock timezone JST 9 0
line console
line vty
boot kickstart {{ op://Network/nexus3548/boot_kickstart_image }}
boot system {{ op://Network/nexus3548/boot_system_image }}
