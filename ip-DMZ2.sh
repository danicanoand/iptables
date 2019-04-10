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
iptables -A INPUT -s 192.168.0.10 -p udp -m udp --sport 53 -j ACCEPT
iptables -A OUTPUT -d 192.168.0.10 -p udp -m udp --dport 53 -j ACCEPT
# consulta dns secundari
iptables -A INPUT -s 10.1.1.200 -p udp -m udp --sport 53 -j ACCEPT
iptables -A OUTPUT -d 10.1.1.200 -p udp -m udp --dport 53 -j ACCEPT
# consulta dns terciari
iptables -A INPUT -s 208.67.222.222 -p udp -m udp --sport 53 -j ACCEPT
iptables -A OUTPUT -d 208.67.222.222 -p udp -m udp --dport 53 -j ACCEPT
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
iptables -A INPUT -p tcp --sport 22 -m tcp -m state --state RELATED,ESTABLISHED -j ACCEPT
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
# ...
#NAT per les xarxes internes 
#netA
#netB
#netDMZ
iptables -t nat -A POSTROUTING -s 172.21.0.0/24 -o enp5s0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.22.0.0/24 -o enp5s0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.23.0.0/24 -o enp5s0 -j MASQUERADE

#de la xarxaA només es pot accedir del router/fireall als serveis: ssh i daytime(13)
iptables -A INPUT -s 172.21.0.0/16 -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -s 172.21.0.0/16 -p tcp --dport 13 -j ACCEPT
iptables -A INPUT -s 172.21.0.0/16 -p tcp  -j REJECT

#de la xarxaA només es pot accedir a l'exterior als serveis web, ssh i daytime(2013)
iptables -A FORWARD -p tcp -s 172.21.0.0/16 -o enp5s0 --dport 80 -j ACCEPT
iptables -A FORWARD -p tcp -s 172.21.0.0/16 -o enp5s0 --dport 443 -j ACCEPT
iptables -A FORWARD -p tcp -s 172.21.0.0/16 -o enp5s0 --dport 22 -j ACCEPT
iptables -A FORWARD -p tcp -s 172.21.0.0/16 -o enp5s0 --dport 2013 -j ACCEPT
iptables -A FORWARD -p tcp -d 172.21.0.0/16 -i enp5s0 --sport 80 -m tcp -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp -d 172.21.0.0/16 -i enp5s0 --sport 443 -m tcp -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp -d 172.21.0.0/16 -i enp5s0 --sport 22 -m tcp -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp -d 172.21.0.0/16 -i enp5s0 --sport 2013 -m tcp -m state --state RELATED,ESTABLISHED -j ACCEPT

#de la xarxaA només es pot accedir al servei web de la DMZ
 iptables -A FORWARD -p tcp -s 172.21.0.0/16 -d 172.23.0.0/16 --dport 80 -j ACCEPT
 iptables -A FORWARD -p tcp -s 172.21.0.0/16 -d 172.23.0.0/16 -j REJECT

#redirigir els ports perquè des de l'exterior es tingui accés a: 3001->hostA1:80, 3002->hostA2:2013, 3003->hostB1:2080,3004->hostB2:2007
iptables -t nat -A PREROUTING -p tcp -i enp5s0 --dport 3001 -j DNAT --to 172.21.0.2:80
iptables -t nat -A PREROUTING -p tcp -i enp5s0 --dport 3002 -j DNAT --to 172.21.0.3:2013
iptables -t nat -A PREROUTING -p tcp -i enp5s0 --dport 3003 -j DNAT --to 172.22.0.2:2080
iptables -t nat -A PREROUTING -p tcp -i enp5s0 --dport 3004 -j DNAT --to 172.22.0.3:7
iptables -A FORWARD  -s 172.21.0.0/16 -o enp5s0 -j REJECT
iptables -A FORWARD  -d 172.21.0.0/16 -i enp5s0 -j REJECT

#S'habiliten els ports 4001 en endavant per accedir per ssh als ports ssh de: hostA1, hostA2, hostB1, hostB2.
iptables -t nat -A PREROUTING -p tcp -i enp5s0 --dport 4001 -j DNAT --to 172.21.0.2:22
iptables -t nat -A PREROUTING -p tcp -i enp5s0 --dport 4002 -j DNAT --to 172.21.0.3:22
iptables -t nat -A PREROUTING -p tcp -i enp5s0 --dport 4003 -j DNAT --to 172.22.0.2:22
iptables -t nat -A PREROUTING -p tcp -i enp5s0 --dport 4004 -j DNAT --to 172.22.0.3:22

#S'habilita el port 4000 per accedir al port ssh del router/firewal si la ip origen és del host i26.
iptables -t nat -A PREROUTING -s 192.168.2.40 -p tcp --dport 4000 -j DNAT --to 192.168.2.41:22

#Els hosts de la xarxaB tenen accés a tot arreu excepte a la xarxaA.
iptables -A FORWARD -s 172.22.0.0/16 -d 172.21.0.0/16 -j REJECT
iptables -A FORWARD -s 172.22.0.0/16 -j ACCEPT
