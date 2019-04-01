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


#obert a tothom
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
#port 2080 tancat a tothom;reject
iptables -A INPUT -p tcp --dport 2080 -j REJECT
#port 2080 tancat a tothom;drop
iptables -A INPUT -p tcp --dport 2080 -j DROP
#port 3080 tancat a tothom i obert a i26
iptables -A INPUT -p tcp --dport 3080 -s 192.168.2.56 -j ACCEPT
iptables -A INPUT -p tcp --dport 3080 -j DROP
#port 4080 obert a tothom i tancat a i26
iptables -A INPUT -p tcp --dport 4080 -s 192.168.2.56 -j DROP
iptables -A INPUT -p tcp --dport 4080 -j ACCEPT
#port 5080 tancat a tothom obert a hisx2 tancat a i26
iptables -A INPUT -p tcp --dport 5080 -s 192.168.2.56 -j REJECT
iptables -A INPUT -p tcp --dport 5080 -s 192.168.2.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 5080 -j DROP


