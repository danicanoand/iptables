#! /bin/bash
# @edt ASIX M11-SAD Curs 2018-19
# Iptables

#El sistema es comporti com un router
#echo 1 > /proc/sys/ipv4/ip_forward

#Regles flush: tirar de la cadena
iptables -F 
iptables -X
iptables -Z
iptables -t nat -F

# Establir la política per defecte (ACCEPT o DROP) : dir si a todo
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT

#Obrir el localhost : tot lo que sigui de mi , a mi mateix , podem cinsultar nosaltres
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Permetre tot el trafic de la pròpia ip (obrim la nostra ip)
iptables -A INPUT -s 192.168.2.52 -j ACCEPT
iptables -A OUTPUT -d  192.168.2.52 -j ACCEPT
iptables -A INPUT -s 172.209.0.1 -j ACCEPT
iptables -A OUTPUT -d  172.209.0.1 -j ACCEPT

#(1) el router fa NAT de la xarxa interna
iptables -t nat -A POSTROUTING -s 172.209.0.0/16 -o enp5s0 -j MASQUERADE

#(2) en el router el port 3001 porta a un servei del host1 i el port 3002 a un servei del host2.
iptables -t nat -A PREROUTING -i enp5s0 -p tcp --dport 3001 -j DNAT --to 172.209.0.2:7
iptables -t nat -A PREROUTING -i enp5s0 -p tcp --dport 3002 -j DNAT --to 172.209.0.3:13

#(3) en el router el port 4001 porta al servei ssh del host1 i el port 4002 al servei ssh del host2.
iptables -t nat -A PREROUTING -i enp5s0 -p tcp --dport 4001 -j DNAT --to 172.209.0.2:22
iptables -t nat -A PREROUTING -i enp5s0 -p tcp --dport 4002 -j DNAT --to 172.209.0.3:22

#(4) en el router el port 4000 porta al servei ssh del propi router.
iptables -t nat -A PREROUTING -i enp5s0 -p tcp --dport 4000 -j DNAT --to 172.209.0.1:22

#(5) als hosts de la xarxa privada interna se'ls permet navegar per internet, però no cap altre accés a internet.
iptables -A FORWARD -s 172.209.0.0/16 -o enp5s0 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -d 172.209.0.0/16 -i enp5s0 -p tcp --sport 80  -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -A FORWARD  -d 172.209.0.2 -i enp5s0 -p tcp --dport 7 -j ACCEPT  
iptables -A FORWARD  -s 172.209.0.2 -o enp5s0 -p tcp --sport 7 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD  -d 172.209.0.3 -i enp5s0 -p tcp --dport 13 -j ACCEPT  
iptables -A FORWARD  -s 172.209.0.3 -o enp5s0 -p tcp --sport 13 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD  -d 172.209.0.2 -i enp5s0 -p tcp --dport 22 -j ACCEPT  
iptables -A FORWARD  -s 172.209.0.2 -o enp5s0 -p tcp --sport 22 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD  -d 172.209.0.3 -i enp5s0 -p tcp --dport 22 -j ACCEPT  
iptables -A FORWARD  -s 172.209.0.3 -o enp5s0 -p tcp --sport 22 -m state --state ESTABLISHED,RELATED -j ACCEPT

#XApa tot i no volem
#iptables -A FORWARD -s 172.200.0.0/16 -o enp5s0 -j DROP
#iptables -A FORWARD -d 172.200.0.0/16 -i enp5s0 -j DROP

iptables -A FORWARD -s 172.209.0.0/16 -o enp5s0 -p tcp -j DROP
iptables -A FORWARD -d 172.209.0.0/16 -i enp5s0 -p tcp -j DROP
iptables -A FORWARD -s 172.209.0.0/16 -o enp5s0 -p udp -j DROP
iptables -A FORWARD -d 172.209.0.0/16 -i enp5s0 -p udp -j DROP
 
#(6) no es permet que els hosts de la xarxa interna facin ping a l'exterior.
iptables -A FORWARD -s 172.209.0.0/16 -p icmp --icmp-type=8 -o enp5s0 -j DROP

## ICMP  echo-requets:8 (peticio), echo-reply:0 (respuesta)
###(7) el router no contesta als pings que rep, però si que pot fer ping.
iptables -A INPUT -p icmp --icmp-type 8 -j DROP
iptables -A OUTPUT -p icmp --icmp-type 0 -j DROP
