hostname "almond"
trunk 25-26 trk1 lacp
no telnet-server
ip default-gateway 192.168.4.1
snmp-server community "{{ op://Network/almond/snmp_community }}" operator
aaa authentication ssh enable public-key
vlan 1
   name "DEFAULT_VLAN"
   no untagged 1-24,Trk1
   untagged 27-28
   no ip address
   exit
vlan 10
   name "Management"
   untagged 23-24
   tagged 2,Trk1
   ip address 192.168.4.3 255.255.255.0
   exit
vlan 20
   name "WAN"
   tagged Trk1
   no ip address
   exit
vlan 100
   name "server"
   untagged 5-22
   tagged 1,Trk1
   no ip address
   exit
vlan 200
   name "user"
   untagged 3-4
   tagged 1,Trk1
   no ip address
   exit
vlan 250
   name "ix2215-map-e-ipv4-transit"
   untagged 2
   tagged Trk1
   no ip address
   exit
vlan 251
   name "ix2215-map-e-ipv6-transit"
   untagged 1
   tagged Trk1
   no ip address
   exit
spanning-tree
spanning-tree Trk1 priority 4
allow-unsupported-transceiver
password {{ op://Network/almond/manager_password }}
