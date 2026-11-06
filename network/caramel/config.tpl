hostname caramel
timezone +09 00
!
logging buffered 131072
logging subsystem all warn
no logging subsystem mape
logging timestamp datetime
!
no syslog ip enable
!
username juglans password hash {{ op://Network/caramel/admin_password_hash }} administrator
!
ntp server {{ op://Network/caramel/ntp_server }}
ntp retry 10
ntp interval 3600
!
!
ip ufs-cache max-entries 20000
ip ufs-cache enable
ip route default Tunnel0.0
ip route 192.168.0.0/24 192.168.252.1
ip route 192.168.100.0/24 192.168.252.1
ip dhcp enable
ip prefix-list default-only 10 permit 0.0.0.0/0
ip prefix-list vyos-user 10 permit 192.168.100.0/24
ip access-list mgmt-acl permit ip src 192.168.100.6/32 dest any
ip access-list mgmt-acl permit ip src 192.168.100.7/32 dest any
ip access-list mgmt-acl permit ip src 192.168.4.0/24 dest any
ip access-list mgmt-acl deny ip src any dest any
ip access-list snmp-acl permit ip src 192.168.0.0/16 dest any
!
!
ipv6 ufs-cache max-entries 10000
ipv6 ufs-cache enable
ipv6 dhcp enable
ipv6 access-list block-list deny ip src any dest any
ipv6 access-list permit-list permit ip src any dest any
ipv6 access-list wan-permit-list permit udp src any sport any dest any dport eq 546
ipv6 access-list wan-permit-list permit udp src any sport any dest any dport eq 547
ipv6 access-list wan-permit-list permit icmp src any dest any
ipv6 access-list wan-permit-list permit 4 src any dest any
ipv6 access-list dynamic cache 65535
ipv6 access-list dynamic dflt-list access permit-list
!
!
snmp-agent ip enable
snmp-agent ip community {{ op://Network/caramel/snmp_community }} snmp-acl
!
!
!
!
!
!
!
ip name-server {{ op://Network/caramel/name_server_1 }}
ip name-server {{ op://Network/caramel/name_server_2 }}
ipv6 name-server 2606:4700:4700::1111
ipv6 name-server 2606:4700:4700::1001
dns cache enable
!
!
ssh-server ip access-list mgmt-acl
ssh-server ip enable
!
http-server username juglans
http-server ip access-list mgmt-acl
http-server ip enable
!
!
!
!
watch-group mape-health 10
  event 10 ip unreach-host {{ op://Network/caramel/unreachable_host }} Tunnel0.0
  action 10 ip shutdown-route 0.0.0.0/0 Tunnel0.0
!
network-monitor mape-health directed-response
network-monitor mape-health enable
!
!
route-map vyos-in permit 10
  match ip address prefix-list vyos-user
!
route-map vyos-in deny 100
!
route-map vyos-out permit 10
  match ip address prefix-list default-only
!
route-map vyos-out deny 100
!
router bgp 65002
  router-id 192.168.252.2
  neighbor 192.168.252.1 remote-as 65001
  neighbor 192.168.252.1 timers 4 9
  address-family ipv4 unicast
    originate-default
    neighbor 192.168.252.1 route-map vyos-in in
    neighbor 192.168.252.1 route-map vyos-out out
!
device GigaEthernet0
!
device GigaEthernet1
!
device GigaEthernet2
!
device BRI0
  isdn switch-type hsd128k
!
device USB0
  shutdown
!
interface GigaEthernet0.0
  description WAN_MAP-E_VLAN251_from_VyOS_PD
  no ip address
  ipv6 enable
  ipv6 address autoconfig receive-default
  ipv6 traffic-class tos 0
  ipv6 filter wan-permit-list 51 in
  ipv6 filter block-list 200 in
  ipv6 filter wan-permit-list 51 out
  ipv6 filter dflt-list 200 out
  no shutdown
!
interface GigaEthernet1.0
  description Transit_to_VyOS_VLAN250
  ip address 192.168.252.2/30
  ip tcp adjust-mss auto
  no shutdown
!
interface GigaEthernet2.0
  no ip address
  shutdown
!
interface BRI0.0
  encapsulation ppp
  no auto-connect
  no ip address
  shutdown
!
interface USB-Serial0.0
  encapsulation ppp
  no auto-connect
  no ip address
  shutdown
!
interface GigaEthernet1.10
  description Management_VLAN10
  encapsulation dot1q 10 tpid 8100
  auto-connect
  ip address 192.168.4.4/24
  no shutdown
!
interface Loopback0.0
  no ip address
!
interface Null0.0
  no ip address
!
interface Tunnel0.0
  description MAP-E_JPIX_for_user_vlan
  tunnel mode map-e jpix
  ip address map-e
  ip tcp adjust-mss auto
  ip napt enable
  no shutdown
!
system information wan 1 GigaEthernet0.0
system information wan 2 Tunnel0.0
!
web-console system information
  o wizard easy-ipv6-ipoe jpix-ipv4-6
