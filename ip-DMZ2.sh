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
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
iptables -t nat -P PREROUTING DROP
iptables -t nat -P POSTROUTING DROP

# Permetre totes les pròpies connexions via localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Permetre tot el trafic de la nostra pròpia ip
iptables -A INPUT -s 192.168.2.41 -j ACCEPT
iptables -A OUTPUT -d 192.168.2.41 -j ACCEPT
# -----------------------------------------------------------
# consulta dns primari
iptables -A INPUT -s 1.1.1.1/0 -p udp -m udp --sport 53 -j ACCEPT
iptables -A OUTPUT -d 1.1.1.1/0 -p udp -m udp --dport 53 -j ACCEPT
iptables -A INPUT -s 1.1.1.1/0 -p tcp -m tcp --sport 53 -j ACCEPT
iptables -A OUTPUT -d 1.1.1.1/0 -p tcp -m tcp --dport 53 -j ACCEPT
# dhcp
iptables -A INPUT -p udp -m udp --dport 67 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 68 -j ACCEPT
iptables -A OUTPUT -p udp -m udp --sport 67 -j ACCEPT
iptables -A OUTPUT -p udp -m udp --sport 68 -j ACCEPT

# consulta ntp
iptables -A INPUT -p udp -m udp --dport 123 -j ACCEPT
iptables -A OUTPUT -p udp -m udp --sport 123 -j ACCEPT
# -----------------------------------------------------------
# servei cups
iptables -A INPUT -p tcp --dport 631 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 631 -j ACCEPT
# port xinetd
iptables -A INPUT -p tcp --dport 3411 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 3411 -j ACCEPT
# port x11-x-forwarding
iptables -A INPUT -p tcp --dport 6010 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 6010 -j ACCEPT
# servei rpc
iptables -A INPUT -p tcp --dport 111 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 111 -j ACCEPT
# servei chronyd
iptables -A OUTPUT -p tcp --dport 323 -j ACCEPT
iptables -A INPUT -p tcp --sport 323 -m tcp -m state --state RELATED,ESTABLISHED -j ACCEPT
# -----------------------------------------------------------
# icmp
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
# -----------------------------------------------------------
# servei smtp
iptables -A INPUT -p tcp --dport 25 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 25 -j ACCEPT
# -----------------------------------------------------------
# navegar web
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --sport 80 -m tcp -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --sport 443 -m tcp -m state --state RELATED,ESTABLISHED -j ACCEPT

# accedir a servei echo
iptables -A OUTPUT -p tcp --dport 7 -j ACCEPT
iptables -A INPUT -p tcp --sport 7 -m tcp -m state --state RELATED,ESTABLISHED -j ACCEPT
# accedir al servei daytime
iptables -A OUTPUT -p tcp --dport 13 -j ACCEPT
iptables -A INPUT -p tcp --sport 13 -m tcp -m state --state RELATED,ESTABLISHED -j ACCEPT
# accedir al servei ssh
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --sport 22 -j ACCEPT
iptables -A INPUT -p tcp --sport 22 -m tcp -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 22 -m tcp -m state --state RELATED,ESTABLISHED -j ACCEPT
# -----------------------------------------------------------------
#ldap
iptables -A OUTPUT -p tcp --dport 389 -j ACCEPT
iptables -A INPUT -p tcp --sport 389 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 636 -j ACCEPT
iptables -A INPUT -p tcp --sport 636 -j ACCEPT
#kerberos
iptables -A OUTPUT -p tcp --dport 88 -j ACCEPT
iptables -A INPUT -p tcp --sport 88 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 464 -j ACCEPT
iptables -A INPUT -p tcp --sport 464 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 749 -j ACCEPT
iptables -A INPUT -p tcp --sport 749 -j ACCEPT
#

# -----------------------------------------------------------------
# ftp i tftp (trafic udp)
# -----------------------------------------------------------------
# oferir servei tftp
iptables -A INPUT -p udp --dport 69 -j ACCEPT
iptables -A OUTPUT -p udp --sport 69 -j ACCEPT
# accedir a serveis tftp externs
iptables -A INPUT -p udp --sport 69 -j ACCEPT
iptables -A OUTPUT -p udp --dport 69 -j ACCEPT
# pendent obrir ports dinamics
# oferir servei ftp
iptables -A INPUT -p tcp --dport 20:21 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 20:21 -j ACCEPT
# accdir a serveis ftp externs
iptables -A INPUT -p tcp --sport 20:21 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 20:21 -j ACCEPT
# pendent obrir ports dinamics!
# --------------------------------------------------------------
# Barrera per tancar els serveis/ports en cas de passar a drop
# ldap
iptables -A INPUT -p tcp --dport 53110 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 53110 -j ACCEPT

#NAT per les xarxes internes 
#netA
#netB
#netDMZ
iptables -t nat -A POSTROUTING -s 172.21.0.0/24 -o enp5s0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.22.0.0/24 -o enp5s0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.23.0.0/24 -o enp5s0 -j MASQUERADE

