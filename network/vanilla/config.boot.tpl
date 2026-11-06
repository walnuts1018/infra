firewall {
    group {
        address-group TRUSTED_USERS {
            address "192.168.100.4"
            address "192.168.100.6"
            address "192.168.100.7"
            address "192.168.100.11"
        }
        port-group MAIL_PORTS {
            port "25"
            port "465"
            port "587"
            port "993"
        }
        port-group WEB_PORTS {
            port "80"
            port "443"
        }
    }
    ipv4 {
        forward {
            filter {
                default-action "drop"
                rule 1 {
                    action "drop"
                    state "invalid"
                }
                rule 10 {
                    action "accept"
                    state "established"
                    state "related"
                }
                rule 30 {
                    action "accept"
                    protocol "icmp"
                }
                rule 100 {
                    action "accept"
                    destination {
                        address "192.168.0.0/24"
                    }
                    inbound-interface {
                        name "eth0.200"
                    }
                    source {
                        group {
                            address-group "TRUSTED_USERS"
                        }
                    }
                }
                rule 125 {
                    action "accept"
                    destination {
                        address "192.168.12.138"
                        group {
                            port-group "WEB_PORTS"
                        }
                    }
                    inbound-interface {
                        name "eth0.200"
                    }
                    protocol "tcp"
                    source {
                        address "192.168.100.0/24"
                    }
                }
                rule 126 {
                    action "accept"
                    description "user VLAN hairpin mail to ingress"
                    destination {
                        address "192.168.12.138"
                        group {
                            port-group "MAIL_PORTS"
                        }
                    }
                    inbound-interface {
                        name "eth0.200"
                    }
                    protocol "tcp"
                    source {
                        address "192.168.100.0/24"
                    }
                }
                rule 130 {
                    action "drop"
                    destination {
                        address "192.168.0.0/24"
                    }
                    inbound-interface {
                        name "eth0.200"
                    }
                    source {
                        address "192.168.100.0/24"
                    }
                }
                rule 140 {
                    action "accept"
                    description "server VLAN hairpin WEB to ingress"
                    destination {
                        address "192.168.12.138"
                        group {
                            port-group "WEB_PORTS"
                        }
                    }
                    inbound-interface {
                        name "eth0.100"
                    }
                    outbound-interface {
                        name "eth0.100"
                    }
                    protocol "tcp"
                    source {
                        address "192.168.0.0/24"
                    }
                }
                rule 145 {
                    action "accept"
                    description "server VLAN hairpin mail to ingress"
                    destination {
                        address "192.168.12.138"
                        group {
                            port-group "MAIL_PORTS"
                        }
                    }
                    inbound-interface {
                        name "eth0.100"
                    }
                    outbound-interface {
                        name "eth0.100"
                    }
                    protocol "tcp"
                    source {
                        address "192.168.0.0/24"
                    }
                }
                rule 160 {
                    action "accept"
                    description "server VLAN to esp32_thermohygrometer"
                    destination {
                        address "192.168.100.11"
                        group {
                            port-group "WEB_PORTS"
                        }
                    }
                    inbound-interface {
                        name "eth0.100"
                    }
                    outbound-interface {
                        name "eth0.200"
                    }
                    protocol "tcp"
                    source {
                        address "192.168.0.0/24"
                    }
                }
                rule 200 {
                    action "accept"
                    inbound-interface {
                        name "eth0.100"
                    }
                    outbound-interface {
                        name "tun0"
                    }
                }
                rule 204 {
                    action "accept"
                    description "server VLAN to management subnet"
                    destination {
                        address "192.168.4.0/24"
                    }
                    inbound-interface {
                        name "eth0.100"
                    }
                    outbound-interface {
                        name "eth0.10"
                    }
                    source {
                        address "192.168.0.0/24"
                    }
                }
                rule 205 {
                    action "accept"
                    description "trusted user to management subnet"
                    destination {
                        address "192.168.4.0/24"
                    }
                    inbound-interface {
                        name "eth0.200"
                    }
                    outbound-interface {
                        name "eth0.10"
                    }
                    source {
                        address "192.168.100.6"
                    }
                }
                rule 206 {
                    action "drop"
                    description "block user VLAN to management subnet"
                    destination {
                        address "192.168.4.0/24"
                    }
                    inbound-interface {
                        name "eth0.200"
                    }
                    source {
                        address "192.168.100.0/24"
                    }
                }
                rule 207 {
                    action "accept"
                    description "trusted user to management subnet"
                    destination {
                        address "192.168.4.0/24"
                    }
                    inbound-interface {
                        name "eth0.200"
                    }
                    outbound-interface {
                        name "eth0.10"
                    }
                    source {
                        address "192.168.100.7"
                    }
                }
                rule 210 {
                    action "accept"
                    inbound-interface {
                        name "eth0.200"
                    }
                    outbound-interface {
                        name "eth0.250"
                    }
                }
                rule 211 {
                    action "accept"
                    description "user VLAN fallback to fixed IPv4"
                    inbound-interface {
                        name "eth0.200"
                    }
                    outbound-interface {
                        name "tun0"
                    }
                }
                rule 250 {
                    action "accept"
                    description "allow any to 192.168.12.0/24"
                    destination {
                        address "192.168.12.0/24"
                    }
                    source {
                        address "192.168.0.0/16"
                    }
                }
                rule 251 {
                    action "accept"
                    description "allow any to 192.168.16.0/24"
                    destination {
                        address "192.168.16.0/24"
                    }
                    source {
                        address "192.168.0.0/16"
                    }
                }
                rule 300 {
                    action "accept"
                    description "fixed IPv4 WEB to ingress"
                    destination {
                        address "192.168.12.138"
                        group {
                            port-group "WEB_PORTS"
                        }
                    }
                    inbound-interface {
                        name "tun0"
                    }
                    outbound-interface {
                        name "eth0.100"
                    }
                    protocol "tcp"
                }
                rule 301 {
                    action "accept"
                    description "fixed IPv4 NetBird STUN to Kubernetes"
                    destination {
                        address "192.168.12.142"
                        port "3478"
                    }
                    inbound-interface {
                        name "tun0"
                    }
                    outbound-interface {
                        name "eth0.100"
                    }
                    protocol "udp"
                }
                rule 302 {
                    action "accept"
                    description "fixed IPv4 mail to ingress"
                    destination {
                        address "192.168.12.138"
                        group {
                            port-group "MAIL_PORTS"
                        }
                    }
                    inbound-interface {
                        name "tun0"
                    }
                    outbound-interface {
                        name "eth0.100"
                    }
                    protocol "tcp"
                }
                rule 303 {
                    action "accept"
                    description "fixed IPv4 HTTP/3 to ingress"
                    destination {
                        address "192.168.12.138"
                        port "443"
                    }
                    inbound-interface {
                        name "tun0"
                    }
                    outbound-interface {
                        name "eth0.100"
                    }
                    protocol "udp"
                }
                rule 304 {
                    action "accept"
                    description "fixed IPv4 Webtop WebRTC to Kubernetes"
                    destination {
                        address "192.168.12.143"
                        port "59000"
                    }
                    inbound-interface {
                        name "tun0"
                    }
                    outbound-interface {
                        name "eth0.100"
                    }
                    protocol "udp"
                }
            }
        }
        input {
            filter {
                default-action "drop"
                rule 1 {
                    action "drop"
                    state "invalid"
                }
                rule 10 {
                    action "accept"
                    state "established"
                    state "related"
                }
                rule 20 {
                    action "accept"
                    inbound-interface {
                        name "lo"
                    }
                }
                rule 30 {
                    action "accept"
                    protocol "icmp"
                }
                rule 40 {
                    action "accept"
                    destination {
                        port "22"
                    }
                    protocol "tcp"
                    source {
                        address "192.168.0.0/24"
                    }
                }
                rule 50 {
                    action "accept"
                    destination {
                        port "22"
                    }
                    protocol "tcp"
                    source {
                        address "192.168.100.4"
                    }
                }
                rule 60 {
                    action "accept"
                    destination {
                        address "192.168.4.1"
                        port "22"
                    }
                    protocol "tcp"
                    source {
                        address "192.168.100.6"
                    }
                }
                rule 70 {
                    action "accept"
                    destination {
                        address "192.168.4.1"
                        port "22"
                    }
                    protocol "tcp"
                    source {
                        address "192.168.4.0/24"
                    }
                }
                rule 80 {
                    action "accept"
                    destination {
                        address "192.168.4.1"
                        port "22"
                    }
                    protocol "tcp"
                    source {
                        address "192.168.100.7"
                    }
                }
                rule 100 {
                    action "accept"
                    destination {
                        port "53"
                    }
                    protocol "tcp_udp"
                    source {
                        address "192.168.0.0/24"
                    }
                }
                rule 110 {
                    action "accept"
                    destination {
                        port "53"
                    }
                    protocol "tcp_udp"
                    source {
                        address "192.168.100.0/24"
                    }
                }
                rule 120 {
                    action "accept"
                    destination {
                        port "67"
                    }
                    inbound-interface {
                        name "eth0.100"
                    }
                    protocol "udp"
                }
                rule 130 {
                    action "accept"
                    destination {
                        port "67"
                    }
                    inbound-interface {
                        name "eth0.200"
                    }
                    protocol "udp"
                }
                rule 140 {
                    action "accept"
                    destination {
                        port "161"
                    }
                    protocol "udp"
                    source {
                        address "192.168.0.0/24"
                    }
                }
                rule 145 {
                    action "accept"
                    destination {
                        port "9273"
                    }
                    protocol "tcp"
                    source {
                        address "192.168.0.0/24"
                    }
                }
                rule 150 {
                    action "accept"
                    destination {
                        port "179"
                    }
                    protocol "tcp"
                    source {
                        address "192.168.0.0/24"
                    }
                }
                rule 155 {
                    action "accept"
                    destination {
                        port "179"
                    }
                    protocol "tcp"
                    source {
                        address "192.168.252.0/30"
                    }
                }
                rule 160 {
                    action "accept"
                    destination {
                        port "123"
                    }
                    protocol "udp"
                    source {
                        address "192.168.0.0/16"
                    }
                }
            }
        }
    }
    ipv6 {
        forward {
            filter {
                default-action "drop"
                rule 10 {
                    action "drop"
                    state "invalid"
                }
                rule 20 {
                    action "accept"
                    state "established"
                    state "related"
                }
                rule 30 {
                    action "accept"
                    protocol "icmpv6"
                }
                rule 100 {
                    action "accept"
                    inbound-interface {
                        name "eth0.100"
                    }
                    outbound-interface {
                        name "eth0.20"
                    }
                }
                rule 110 {
                    action "accept"
                    inbound-interface {
                        name "eth0.200"
                    }
                    outbound-interface {
                        name "eth0.20"
                    }
                }
                rule 115 {
                    action "accept"
                    description "MAP-E outer IPv4-in-IPv6 to IX2215"
                    inbound-interface {
                        name "eth0.20"
                    }
                    outbound-interface {
                        name "eth0.251"
                    }
                    protocol "4"
                }
                rule 120 {
                    action "accept"
                    inbound-interface {
                        name "eth0.251"
                    }
                    outbound-interface {
                        name "eth0.20"
                    }
                }
            }
        }
        input {
            filter {
                default-action "drop"
                rule 10 {
                    action "drop"
                    state "invalid"
                }
                rule 20 {
                    action "accept"
                    state "established"
                    state "related"
                }
                rule 30 {
                    action "accept"
                    protocol "icmpv6"
                }
                rule 40 {
                    action "accept"
                    inbound-interface {
                        name "lo"
                    }
                }
                rule 50 {
                    action "accept"
                    destination {
                        port "546"
                    }
                    inbound-interface {
                        name "eth0.20"
                    }
                    protocol "udp"
                    source {
                        port "547"
                    }
                }
                rule 100 {
                    action "accept"
                    destination {
                        port "53"
                    }
                    inbound-interface {
                        name "eth0.100"
                    }
                    protocol "tcp_udp"
                }
                rule 110 {
                    action "accept"
                    destination {
                        port "53"
                    }
                    inbound-interface {
                        name "eth0.200"
                    }
                    protocol "tcp_udp"
                }
            }
        }
    }
}
interfaces {
    ethernet eth0 {
        description "wan-and-lan"
        disable-flow-control
        hw-id "{{ op://Network/vanilla/interface_eth0_mac }}"
        vif 10 {
            address "192.168.4.1/24"
            description "management"
        }
        vif 20 {
            address "dhcpv6"
            description "wan"
            dhcpv6-options {
                duid "{{ op://Network/vanilla/dhcpv6_duid }}"
                pd 0 {
                    interface eth0.100 {
                        address "1"
                        sla-id "1"
                    }
                    interface eth0.200 {
                        address "1"
                        sla-id "2"
                    }
                    interface eth0.251 {
                        address "31354384210198528"
                        sla-id "0"
                    }
                    length "56"
                }
            }
            ipv6 {
                address {
                    autoconf
                }
            }
        }
        vif 100 {
            address "192.168.0.1/24"
            address "fd7e:bc2d:5f4a:100::1/64"
            description "server"
            ip {
                adjust-mss "clamp-mss-to-pmtu"
            }
        }
        vif 200 {
            address "192.168.100.1/24"
            address "fd7e:bc2d:5f4a:200::1/64"
            description "user"
            ip {
                adjust-mss "clamp-mss-to-pmtu"
            }
        }
        vif 250 {
            address "192.168.252.1/30"
            description "ix2215-map-e-ipv4-transit"
            ip {
                adjust-mss "clamp-mss-to-pmtu"
            }
        }
        vif 251 {
            description "ix2215-map-e-ipv6-transit"
        }
    }
    ethernet eth1 {
        description "onboard"
        hw-id "{{ op://Network/vanilla/interface_eth1_mac }}"
        offload {
            gro
        }
    }
    loopback lo {
    }
    tunnel tun0 {
        address "{{ op://Network/vanilla/wan_ipv4 }}/32"
        description "v6plus static 4-over-6"
        encapsulation "ipip6"
        ip {
            adjust-mss "clamp-mss-to-pmtu"
        }
        mtu "1460"
        remote "{{ op://Network/vanilla/tunnel_remote_ipv6 }}"
    }
    wireless wlan0 {
        hw-id "{{ op://Network/vanilla/interface_wlan0_mac }}"
        physical-device "phy0"
    }
}
nat {
    destination {
        rule 100 {
            description "HTTP to ingress"
            destination {
                port "80"
            }
            inbound-interface {
                name "tun0"
            }
            protocol "tcp"
            translation {
                address "192.168.12.138"
            }
        }
        rule 110 {
            description "HTTPS to ingress"
            destination {
                port "443"
            }
            inbound-interface {
                name "tun0"
            }
            protocol "tcp"
            translation {
                address "192.168.12.138"
            }
        }
        rule 115 {
            description "HTTP/3 to ingress"
            destination {
                port "443"
            }
            inbound-interface {
                name "tun0"
            }
            protocol "udp"
            translation {
                address "192.168.12.138"
            }
        }
        rule 120 {
            description "NetBird STUN"
            destination {
                port "3478"
            }
            inbound-interface {
                name "tun0"
            }
            protocol "udp"
            translation {
                address "192.168.12.142"
            }
        }
        rule 125 {
            description "Webtop WebRTC"
            destination {
                port "59000"
            }
            inbound-interface {
                name "tun0"
            }
            protocol "udp"
            translation {
                address "192.168.12.143"
            }
        }
        rule 130 {
            description "SMTP to ingress"
            destination {
                port "25"
            }
            inbound-interface {
                name "tun0"
            }
            protocol "tcp"
            translation {
                address "192.168.12.138"
            }
        }
        rule 140 {
            description "SMTPS to ingress"
            destination {
                port "465"
            }
            inbound-interface {
                name "tun0"
            }
            protocol "tcp"
            translation {
                address "192.168.12.138"
            }
        }
        rule 150 {
            description "Submission to ingress"
            destination {
                port "587"
            }
            inbound-interface {
                name "tun0"
            }
            protocol "tcp"
            translation {
                address "192.168.12.138"
            }
        }
        rule 160 {
            description "IMAPS to ingress"
            destination {
                port "993"
            }
            inbound-interface {
                name "tun0"
            }
            protocol "tcp"
            translation {
                address "192.168.12.138"
            }
        }
        rule 200 {
            description "server VLAN hairpin HTTP to ingress"
            destination {
                address "{{ op://Network/vanilla/wan_ipv4 }}"
                port "80"
            }
            inbound-interface {
                name "eth0.100"
            }
            protocol "tcp"
            source {
                address "192.168.0.0/16"
            }
            translation {
                address "192.168.12.138"
            }
        }
        rule 210 {
            description "server VLAN hairpin HTTPS to ingress"
            destination {
                address "{{ op://Network/vanilla/wan_ipv4 }}"
                port "443"
            }
            inbound-interface {
                name "eth0.100"
            }
            protocol "tcp"
            source {
                address "192.168.0.0/16"
            }
            translation {
                address "192.168.12.138"
            }
        }
        rule 220 {
            description "user VLAN hairpin HTTP to ingress"
            destination {
                address "{{ op://Network/vanilla/wan_ipv4 }}"
                port "80"
            }
            inbound-interface {
                name "eth0.200"
            }
            protocol "tcp"
            source {
                address "192.168.100.0/24"
            }
            translation {
                address "192.168.12.138"
            }
        }
        rule 230 {
            description "user VLAN hairpin HTTPS to ingress"
            destination {
                address "{{ op://Network/vanilla/wan_ipv4 }}"
                port "443"
            }
            inbound-interface {
                name "eth0.200"
            }
            protocol "tcp"
            source {
                address "192.168.100.0/24"
            }
            translation {
                address "192.168.12.138"
            }
        }
        rule 240 {
            description "server VLAN hairpin SMTP to ingress"
            destination {
                address "{{ op://Network/vanilla/wan_ipv4 }}"
                port "25"
            }
            inbound-interface {
                name "eth0.100"
            }
            protocol "tcp"
            source {
                address "192.168.0.0/16"
            }
            translation {
                address "192.168.12.138"
            }
        }
        rule 250 {
            description "server VLAN hairpin SMTPS to ingress"
            destination {
                address "{{ op://Network/vanilla/wan_ipv4 }}"
                port "465"
            }
            inbound-interface {
                name "eth0.100"
            }
            protocol "tcp"
            source {
                address "192.168.0.0/16"
            }
            translation {
                address "192.168.12.138"
            }
        }
        rule 260 {
            description "server VLAN hairpin Submission to ingress"
            destination {
                address "{{ op://Network/vanilla/wan_ipv4 }}"
                port "587"
            }
            inbound-interface {
                name "eth0.100"
            }
            protocol "tcp"
            source {
                address "192.168.0.0/16"
            }
            translation {
                address "192.168.12.138"
            }
        }
        rule 270 {
            description "server VLAN hairpin IMAPS to ingress"
            destination {
                address "{{ op://Network/vanilla/wan_ipv4 }}"
                port "993"
            }
            inbound-interface {
                name "eth0.100"
            }
            protocol "tcp"
            source {
                address "192.168.0.0/16"
            }
            translation {
                address "192.168.12.138"
            }
        }
        rule 280 {
            description "user VLAN hairpin SMTP to ingress"
            destination {
                address "{{ op://Network/vanilla/wan_ipv4 }}"
                port "25"
            }
            inbound-interface {
                name "eth0.200"
            }
            protocol "tcp"
            source {
                address "192.168.100.0/24"
            }
            translation {
                address "192.168.12.138"
            }
        }
        rule 290 {
            description "user VLAN hairpin SMTPS to ingress"
            destination {
                address "{{ op://Network/vanilla/wan_ipv4 }}"
                port "465"
            }
            inbound-interface {
                name "eth0.200"
            }
            protocol "tcp"
            source {
                address "192.168.100.0/24"
            }
            translation {
                address "192.168.12.138"
            }
        }
        rule 300 {
            description "user VLAN hairpin Submission to ingress"
            destination {
                address "{{ op://Network/vanilla/wan_ipv4 }}"
                port "587"
            }
            inbound-interface {
                name "eth0.200"
            }
            protocol "tcp"
            source {
                address "192.168.100.0/24"
            }
            translation {
                address "192.168.12.138"
            }
        }
        rule 310 {
            description "user VLAN hairpin IMAPS to ingress"
            destination {
                address "{{ op://Network/vanilla/wan_ipv4 }}"
                port "993"
            }
            inbound-interface {
                name "eth0.200"
            }
            protocol "tcp"
            source {
                address "192.168.100.0/24"
            }
            translation {
                address "192.168.12.138"
            }
        }
        rule 320 {
            description "server VLAN hairpin Webtop WebRTC"
            destination {
                address "{{ op://Network/vanilla/wan_ipv4 }}"
                port "59000"
            }
            inbound-interface {
                name "eth0.100"
            }
            protocol "udp"
            source {
                address "192.168.0.0/16"
            }
            translation {
                address "192.168.12.143"
            }
        }
        rule 330 {
            description "user VLAN hairpin Webtop WebRTC"
            destination {
                address "{{ op://Network/vanilla/wan_ipv4 }}"
                port "59000"
            }
            inbound-interface {
                name "eth0.200"
            }
            protocol "udp"
            source {
                address "192.168.100.0/24"
            }
            translation {
                address "192.168.12.143"
            }
        }
    }
    source {
        rule 100 {
            description "server VLAN to v6plus"
            outbound-interface {
                name "tun0"
            }
            source {
                address "192.168.0.0/24"
            }
            translation {
                address "masquerade"
            }
        }
        rule 110 {
            description "user VLAN fallback to fixed IPv4"
            outbound-interface {
                name "tun0"
            }
            source {
                address "192.168.100.0/24"
            }
            translation {
                address "masquerade"
            }
        }
        rule 200 {
            description "hairpin to server VLAN"
            destination {
                address "192.168.12.138"
            }
            outbound-interface {
                name "eth0.100"
            }
            protocol "tcp"
            source {
                address "192.168.0.0/16"
            }
            translation {
                address "masquerade"
            }
        }
        rule 210 {
            description "hairpin Webtop WebRTC to server VLAN"
            destination {
                address "192.168.12.143"
            }
            outbound-interface {
                name "eth0.100"
            }
            protocol "udp"
            source {
                address "192.168.0.0/16"
            }
            translation {
                address "masquerade"
            }
        }
    }
}
policy {
    prefix-list CILIUM-LOADBALANCER {
        rule 10 {
            action "permit"
            ge "32"
            le "32"
            prefix "192.168.12.0/24"
        }
        rule 20 {
            action "permit"
            ge "32"
            le "32"
            prefix "192.168.16.0/24"
        }
    }
    prefix-list IX-MAPE-DEFAULT {
        rule 10 {
            action "permit"
            prefix "0.0.0.0/0"
        }
    }
    prefix-list IX-MAPE-OUT {
        rule 10 {
            action "permit"
            prefix "192.168.100.0/24"
        }
    }
    prefix-list K8SVIP-VIP {
        rule 10 {
            action "permit"
            prefix "192.168.4.11/32"
        }
    }
    route V4-EGRESS {
        interface "eth0.100"
        interface "eth0.200"
        rule 10 {
            destination {
                address "10.0.0.0/8"
            }
            set {
                table "main"
            }
        }
        rule 20 {
            destination {
                address "172.16.0.0/12"
            }
            set {
                table "main"
            }
        }
        rule 30 {
            destination {
                address "192.168.0.0/16"
            }
            set {
                table "main"
            }
        }
        rule 40 {
            destination {
                address "100.64.0.0/10"
            }
            set {
                table "main"
            }
        }
        rule 50 {
            destination {
                address "{{ op://Network/vanilla/wan_ipv4 }}/32"
            }
            set {
                table "main"
            }
        }
        rule 100 {
            set {
                table "100"
            }
            source {
                address "192.168.0.0/24"
            }
        }
        rule 110 {
            set {
                table "200"
            }
            source {
                address "192.168.100.0/24"
            }
        }
    }
    route-map CILIUM-IN {
        rule 10 {
            action "permit"
            match {
                ip {
                    address {
                        prefix-list "CILIUM-LOADBALANCER"
                    }
                }
            }
        }
        rule 20 {
            action "permit"
            match {
                ip {
                    address {
                        prefix-list "K8SVIP-VIP"
                    }
                }
            }
        }
        rule 100 {
            action "deny"
        }
    }
    route-map CILIUM-OUT {
        rule 100 {
            action "deny"
        }
    }
    route-map IX-MAPE-IN {
        rule 10 {
            action "permit"
            match {
                ip {
                    address {
                        prefix-list "IX-MAPE-DEFAULT"
                    }
                }
            }
            set {
                distance "20"
                table "200"
            }
        }
        rule 100 {
            action "deny"
        }
    }
    route-map IX-MAPE-OUT {
        rule 10 {
            action "permit"
            match {
                ip {
                    address {
                        prefix-list "IX-MAPE-OUT"
                    }
                }
            }
        }
        rule 100 {
            action "deny"
        }
    }
}
protocols {
    bgp {
        address-family {
            ipv4-unicast {
                network 192.168.100.0/24 {
                }
            }
        }
        listen {
            limit "32"
            range 192.168.0.0/24 {
                peer-group "CILIUM"
            }
        }
        neighbor 192.168.252.2 {
            address-family {
                ipv4-unicast {
                    route-map {
                        export "IX-MAPE-OUT"
                        import "IX-MAPE-IN"
                    }
                }
            }
            description "IX2215 MAP-E"
            remote-as "65002"
            update-source "192.168.252.1"
        }
        parameters {
            router-id "192.168.252.1"
        }
        peer-group CILIUM {
            address-family {
                ipv4-unicast {
                    route-map {
                        export "CILIUM-OUT"
                        import "CILIUM-IN"
                    }
                }
            }
            description "Cilium LoadBalancer IP + kurumi Talos fabric BGP"
            remote-as "65010"
        }
        system-as "65001"
        timers {
            holdtime "9"
            keepalive "4"
        }
    }
    static {
        route 0.0.0.0/0 {
            interface tun0 {
            }
        }
        table 100 {
            route 0.0.0.0/0 {
                interface tun0 {
                }
            }
        }
        table 200 {
            route 0.0.0.0/0 {
                interface tun0 {
                    distance "200"
                }
            }
        }
    }
}
service {
    dhcp-server {
        shared-network-name management {
            authoritative
            option {
                default-router "192.168.4.1"
                name-server "192.168.4.1"
            }
            subnet 192.168.4.0/24 {
                range 0 {
                    start "192.168.4.100"
                    stop "192.168.4.254"
                }
                static-mapping rusk-ilo {
                    ip-address "192.168.4.101"
                    mac "{{ op://Network/vanilla/dhcp_mac_rusk_ilo }}"
                }
                subnet-id "10"
            }
        }
        shared-network-name server {
            authoritative
            option {
                default-router "192.168.0.1"
                name-server "192.168.0.1"
            }
            subnet 192.168.0.0/24 {
                ignore-client-id
                range 0 {
                    start "192.168.0.100"
                    stop "192.168.0.254"
                }
                static-mapping cake {
                    ip-address "192.168.0.25"
                    mac "{{ op://Network/vanilla/dhcp_mac_cake }}"
                }
                static-mapping hotate {
                    ip-address "192.168.0.26"
                    mac "{{ op://Network/vanilla/dhcp_mac_hotate }}"
                }
                static-mapping lemon {
                    ip-address "192.168.0.19"
                    mac "{{ op://Network/vanilla/dhcp_mac_lemon }}"
                }
                static-mapping rusk {
                    ip-address "192.168.0.101"
                    mac "{{ op://Network/vanilla/dhcp_mac_rusk }}"
                }
                static-mapping server-reserved-15 {
                    ip-address "192.168.0.15"
                    mac "{{ op://Network/vanilla/dhcp_mac_server_reserved_15 }}"
                }
                subnet-id "100"
            }
        }
        shared-network-name user {
            authoritative
            option {
                default-router "192.168.100.1"
                name-server "192.168.100.1"
            }
            subnet 192.168.100.0/24 {
                range 0 {
                    start "192.168.100.100"
                    stop "192.168.100.254"
                }
                static-mapping mac {
                    ip-address "192.168.100.7"
                    mac "{{ op://Network/vanilla/dhcp_mac_user_mac }}"
                }
                static-mapping mac-mlo {
                    ip-address "192.168.100.6"
                    mac "{{ op://Network/vanilla/dhcp_mac_user_mac_mlo }}"
                }
                static-mapping user-trusted-4 {
                    ip-address "192.168.100.4"
                    mac "{{ op://Network/vanilla/dhcp_mac_user_trusted_4 }}"
                }
                static-mapping user-trusted-11 {
                    ip-address "192.168.100.11"
                    mac "{{ op://Network/vanilla/dhcp_mac_user_trusted_11 }}"
                }
                subnet-id "200"
            }
        }
    }
    dns {
        forwarding {
            allow-from "192.168.0.0/24"
            allow-from "192.168.100.0/24"
            allow-from "fd7e:bc2d:5f4a:100::/64"
            allow-from "fd7e:bc2d:5f4a:200::/64"
            allow-from "127.0.0.0/8"
            authoritative-domain {{ op://Network/vanilla/dns_authoritative_domain }} {
                records {
                    a @ {
                        address "192.168.0.14"
                        ttl "60"
                    }
                }
            }
            domain {{ op://Network/vanilla/dns_domain }} {
                name-server 192.168.12.135 {
                }
            }
            listen-address "192.168.0.1"
            listen-address "192.168.100.1"
            listen-address "fd7e:bc2d:5f4a:100::1"
            listen-address "fd7e:bc2d:5f4a:200::1"
            listen-address "127.0.0.1"
            name-server {{ op://Network/vanilla/dns_public_ipv4_primary }} {
            }
            name-server {{ op://Network/vanilla/dns_public_ipv4_secondary }} {
            }
            name-server {{ op://Network/vanilla/dns_public_ipv6_primary }} {
            }
            name-server {{ op://Network/vanilla/dns_public_ipv6_secondary }} {
            }
        }
    }
    monitoring {
        telegraf {
            prometheus-client {
                listen-address "192.168.0.1"
                port "9273"
            }
        }
    }
    ntp {
        allow-client {
            address "127.0.0.0/8"
            address "169.254.0.0/16"
            address "10.0.0.0/8"
            address "172.16.0.0/12"
            address "192.168.0.0/16"
            address "::1/128"
            address "fe80::/10"
            address "fc00::/7"
        }
        server {{ op://Network/vanilla/ntp_server }} {
        }
        server {{ op://Network/vanilla/ntp_host_1 }} {
        }
        server {{ op://Network/vanilla/ntp_host_2 }} {
        }
        server {{ op://Network/vanilla/ntp_host_3 }} {
        }
    }
    router-advert {
        interface eth0.100 {
            name-server "fd7e:bc2d:5f4a:100::1"
            prefix ::/64 {
            }
            prefix fd7e:bc2d:5f4a:100::/64 {
            }
        }
        interface eth0.200 {
            name-server "fd7e:bc2d:5f4a:200::1"
            prefix ::/64 {
            }
            prefix fd7e:bc2d:5f4a:200::/64 {
            }
        }
        interface eth0.251 {
            prefix ::/64 {
            }
        }
    }
    ssh {
        disable-password-authentication
        listen-address "192.168.4.1"
        port "22"
    }
}
system {
    config-management {
        commit-revisions "100"
    }
    console {
        device ttyS0 {
            speed "115200"
        }
    }
    host-name "vanilla"
    login {
        user vyos {
            authentication {
                encrypted-password "{{ op://Network/vanilla/login_password_hash }}"
                plaintext-password ""
                public-keys default {
                    key "{{ op://Network/vanilla/ssh_public_key }}"
                    type "ssh-ed25519"
                }
            }
        }
    }
    name-server "192.168.12.135"
    name-server "{{ op://Network/vanilla/dns_public_ipv4_secondary }}"
    option {
        reboot-on-upgrade-failure "5"
    }
    sflow {
        agent-address "192.168.0.1"
        interface "eth0.10"
        interface "eth0.100"
        interface "eth0.200"
        polling "10"
        sampling-rate "64"
        server 192.168.0.25 {
            port "6343"
        }
    }
    syslog {
        local {
            facility all {
                level "info"
            }
            facility local7 {
                level "debug"
            }
        }
        remote 192.168.12.136 {
            facility all {
                level "info"
            }
            format {
                include-timezone
            }
            port "514"
            protocol "udp"
            source-address "192.168.0.1"
        }
    }
    task-scheduler {
        task v6plus-prefix-watch {
            executable {
                path "/config/scripts/v6plus-prefix-watch.sh"
            }
            interval "5m"
        }
    }
    time-zone "Asia/Tokyo"
}


// Warning: Do not remove the following line.
// vyos-config-version: "{{ op://Network/vanilla/config_version }}"
