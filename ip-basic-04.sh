#! /bin/bash
# @edt ASIX M11-SAD Curs 2018-2019 
# iptables

# Activar si el host ha de fer de router
echo 1 > /proc/sys/net/ipv4/ip_forward

# Regles flush
iptables -F
iptables -X
iptables -Z
iptables -t nat -F

#Politiques per defecte (ACCEPT o DROP):
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT

# Permetre totes les pròpies connexions via localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Permetre tot el trafic de la nostra pròpia ip
iptables -A INPUT -s 192.168.2.41 -j ACCEPT
iptables -A OUTPUT -d 192.168.2.41 -j ACCEPT


#ICMP echo-request:8; echo-reply:0
###################################################
# No permetre fer pings cap a lexterior
 #iptables -A OUTPUT -p icmp --icmp-type 8 -j DROP
# No podem fer pings a i05
 #iptables -A OUTPUT -p icmp --icmp-type 8 -d 192.168.2.35 -j DROP
#No permetem respondre als pins que ens facin
 iptables -A OUTPUT -p icmp --icmp-type 0 -j DROP
#No acceptem respostes de pings
 #iptables -A INPUT -p icmp --icmp-type 0 -j DROP
