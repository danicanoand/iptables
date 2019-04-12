#! /bin/bash
# @edt ASIX M11-SAD Curs 2018-2019 
# iptables

# Activar si el host ha de fer de router
#echo 1 > /proc/sys/net/ipv4/ip_forward

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
iptables -A INPUT -s 192.168.2.52 -j ACCEPT
iptables -A OUTPUT -d 192.168.2.52 -j ACCEPT
iptables -A INPUT -s 172.209.0.1 -j ACCEPT
iptables -A OUTPUT -d 172.209.0.1 -j ACCEPT

# (1) el router fa NAT de la xarxa interna 
iptables -t nat -A POSTROUTING -s 172.209.0.0/16 -o enp5s0 -j MASQUERADE

# (2) en el router el port 3001 porta a un servei del host1 i el port 3002 a un servei del host2.
iptables -t nat -A PREROUTING -p tcp --dport 3001 -i enp5s0 -j DNAT --to 172.209.0.2:7
iptables -t nat -A PREROUTING -p tcp --dport 3002 -i enp5s0 -j DNAT --to 172.209.0.3:13

# (3) en el router el port 4001 porta al servei ssh del host1 i el port 4002 al servei ssh del host2.
iptables -t nat -A PREROUTING -p tcp --dport 4001 -i enp5s0 -j DNAT --to 172.209.0.2:22
iptables -t nat -A PREROUTING -p tcp --dport 4002 -i enp5s0 -j DNAT --to 172.209.0.3:22

# (4) en el router el port 4000 porta al servei ssh del propi router.
iptables -t nat -A PREROUTING -p tcp --dport 4000 -i enp5s0 -j DNAT --to 172.209.0.1:22

# (5) als hosts de la xarxa privada interna se'ls permet navegar per internet, però no cap altre accés a internet.
iptables -A FORWARD -p tcp -s 172.209.0.0/16 -o enp5s0 --dport 80 -j ACCEPT
iptables -A FORWARD -p tcp -d 172.209.0.0/16 -i enp5s0 --sport 80 -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -A FORWARD -s 172.209.0.2 -p tcp --dport 7 -o enp5s0  -j ACCEPT
iptables -A FORWARD -d 172.209.0.2 -p tcp --sport 7 -i enp5s0  -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -A FORWARD -s 172.209.0.3 -p tcp --dport 13 -o enp5s0 -j ACCEPT
iptables -A FORWARD -d 172.209.0.3 -p tcp --sport 13 -i enp5s0 -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -A FORWARD -s 172.209.0.0/16 -p tcp --dport 22 -o enp5s0 -j ACCEPT
iptables -A FORWARD -d 172.209.0.0/16 -p tcp --sport 22 -i enp5s0 -m state --state RELATED,ESTABLISHED -j ACCEPT

 # iptables -A FORWARD -d 172.209.0.0/16 -i enp5s0 -j DROP
 # iptables -A FORWARD -s 172.209.0.0/16 -o enp5s0 -j DROP
iptables -A FORWARD -s 172.209.0.0/16 -p tcp -o enp5s0 -j DROP 
iptables -A FORWARD -s 172.209.0.0/16 -p udp -o enp5s0 -j DROP
iptables -A FORWARD -d 172.209.0.0/16 -p tcp -i enp5s0 -j DROP  
iptables -A FORWARD -d 172.209.0.0/16 -p udp -i enp5s0 -j DROP 

# (6) no es permet que els hosts de la xarxa interna facin ping a l'exterior.
iptables -A FORWARD -s 172.209.0.0/16 -p icmp --icmp-type=8 -o enp5s0 -j DROP

# (7) el router no contesta als pings que rep, però si que pot fer ping.
iptables -A INPUT  -p icmp --icmp-type=8 -j DROP
iptables -A OUTPUT -p icmp --icmp-type=0 -j DROP

