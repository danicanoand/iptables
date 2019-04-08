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



#NAT per les xarxes internes 
#netA
#netB
#netDMZ
iptables -t nat -A POSTROUTING -s 172.21.0.0/24 -o enp5s0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.22.0.0/24 -o enp5s0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.23.0.0/24 -o enp5s0 -j MASQUERADE

# Exemples de regles de FORWARD
#############################################################
# Xarxa A no pot accedir a xarxa B
 #iptables -A FORWARD -s 172.21.0.0/16 -d 172.22.0.0/16 -j REJECT
# Ningú de la XarxaA pot Accedir al HostB2
 #iptables -A FORWARD -i br-69badb8e5ec8 -d 172.22.0.3 -j REJECT
 #iptables -A FORWARD -s 172.21.0.0/16 -d 172.22.0.3 -j REJECT
# Impedir que el hostA1 pugui accedir al hostoB1
 #iptables -A FORWARD -s 172.21.0.2 -d 172.22.0.2 -j REJECT
# La xarxaA no es pot conectar a cap port 13
 #iptables -A FORWARD -p tcp -s 172.21.0.0/16 --dport 13 -j REJECT
# xarxaA not pot accedir al port 13 de la xarxaB
 #iptables -A FORWARD -p tcp -s 172.21.0.0/16 -d 172.22.0.0/16 --dport 13 -j REJECT
#Permetre navegar per internet pero res mes a l'exterior
 #iptables -A FORWARD -p tcp -s 172.21.0.0/16 -o enp5s0 --dport 80 -j ACCEPT
 #iptables -A FORWARD -p tcp -d 172.21.0.0/16 -i enp5s0 --sport 80 -m tcp -m state \
  #     --state RELATED,ESTABLISHED -j ACCEPT
 #iptables -A FORWARD  -s 172.21.0.0/16 -o enp5s0 -j REJECT
 #iptables -A FORWARD  -d 172.21.0.0/16 -i enp5s0 -j REJECT
#XarxaA pot accedir al servei 2013 de totes les xarxes de internet excepte de la xarxa hisx2
 #iptables -A FORWARD -p tcp -s 172.21.0.0/16 -d 192.168.2.0/24 -p tcp -o enp5s0 --dport 2013 -j REJECT
 #iptables -A FORWARD -p tcp -d 172.21.0.0/16 -p tcp -o enp5s0 --dport 2013 -j ACCEPT
# Evitar que es fasilfiqui la ip Origen: SPOOFING
# Qualsevol paquet que arribi a br-69badb8e5ec8 que la ip origen no sigui 172.21.0.0/16 DROP
 #iptables -A FORWARD ! -s 172.21.0.0/16 -i br-69badb8e5ec8 -j DROP
