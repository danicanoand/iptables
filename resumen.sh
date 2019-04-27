`Input`'Lo que entra al router'
`Output`'Lo que sale del Router'
`Nat`'Masquerade (Network Address Translation)'
`Forward`'Lo que atraviesa el router'
`Reject`'envia un ICMP (Internet Control Message Protocol)'
`Drop`'No informa'
#Politiques per defecte
`Drop`:'tot tancat, esriure regles per obrir'
`Accept`:'tot obert, escriure regles per tancar'
################# EXEMPLES #############################
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

#INPUT
###################################################
#obert a tothom
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
#port 3080 tancat a tothom i obert a i26
iptables -A INPUT -p tcp --dport 3080 -s 192.168.2.56 -j ACCEPT
iptables -A INPUT -p tcp --dport 3080 -j DROP
#port 4080 obert a tothom i tancat a i26
iptables -A INPUT -p tcp --dport 4080 -s 192.168.2.56 -j DROP
iptables -A INPUT -p tcp --dport 4080 -j ACCEPT
#port 7080 obert a tohom, tancat hisx2, obert a i05
iptables -A INPUT -p tcp --dport 7080 -s 192.168.2.35 -j ACCEPT
iptables -A INPUT -p tcp --dport 7080 -s 192.168.2.0/24 -j DROP
iptables -A INPUT -p tcp --dport 7080 -j ACCEPT

#OUTPUT
###################################################
#accedir a qualsevol destí port/destí
iptables -A OUTPUT  -j ACCEPT
#accedir port 13 de quasevol destí
iptables -A OUTPUT -p tcp --dport 13 -j ACCEPT
#accedir a tothom, tancat a la clase i obert a i05 del port 4013
iptables -A OUTPUT -p tcp --dport 4013 -d 192.168.2.35 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 4013 -d 192.168.2.0/24 -j REJECT
iptables -A OUTPUT -p tcp --dport 4013 -j ACCEPT
#denegar acces als ports 80
iptables -A OUTPUT -p tcp --dport 80 -j REJECT
#a la xarxa hisx2 no es permet accedir excepte per ssh
iptables -A OUTPUT -p tcp --dport 22 -d 192.168.2.0/24 -j ACCEPT
iptables -A OUTPUT -p tcp  -d 192.168.2.0/24 -j REJECT

# Relges related established
###################################################
#oferiri el servei web i permetre nomes resposta a peticions establertes
iptables -A INPUT  -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 80 -m state --state RELATED,ESTABLISHED -j ACCEPT
#filtrant trafic nomes de resposta
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT  -p tcp --sport 80 -m state --state RELATED,ESTABLISHED -j ACCEPT

#ICMP echo-request:8; echo-reply:0
###################################################
# No permetre fer pings cap a lexterior
iptables -A OUTPUT -p icmp --icmp-type 8 -j DROP
# No podem fer pings a i05
iptables -A OUTPUT -p icmp --icmp-type 8 -d 192.168.2.35 -j DROP
#No permetem respondre als pins que ens facin
iptables -A OUTPUT -p icmp --icmp-type 0 -j DROP
#No acceptem respostes de pings
iptables -A INPUT -p icmp --icmp-type 0 -j DROP

#NAT per les xarxes internes, netA; netB; netDMZ
###################################################
iptables -t nat -A POSTROUTING -s 172.21.0.0/24 -o enp5s0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.22.0.0/24 -o enp5s0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.23.0.0/24 -o enp5s0 -j MASQUERADE

# Exemples de regles de FORWARD
#############################################################
# Xarxa A no pot accedir a xarxa B
iptables -A FORWARD -s 172.21.0.0/16 -d 172.22.0.0/16 -j REJECT
# Ningú de la XarxaA pot Accedir al HostB2
iptables -A FORWARD -i br-69badb8e5ec8 -d 172.22.0.3 -j REJECT
iptables -A FORWARD -s 172.21.0.0/16 -d 172.22.0.3 -j REJECT
# Impedir que el hostA1 pugui accedir al hostoB1
iptables -A FORWARD -s 172.21.0.2 -d 172.22.0.2 -j REJECT
# La xarxaA no es pot conectar a cap port 13
iptables -A FORWARD -p tcp -s 172.21.0.0/16 --dport 13 -j REJECT
# xarxaA not pot accedir al port 13 de la xarxaB
iptables -A FORWARD -p tcp -s 172.21.0.0/16 -d 172.22.0.0/16 --dport 13 -j REJECT
#Permetre navegar per internet pero res mes a l'exterior
iptables -A FORWARD -p tcp -s 172.21.0.0/16 -o enp5s0 --dport 80 -j ACCEPT
iptables -A FORWARD -p tcp -d 172.21.0.0/16 -i enp5s0 --sport 80 -m tcp -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD  -s 172.21.0.0/16 -o enp5s0 -j REJECT
iptables -A FORWARD  -d 172.21.0.0/16 -i enp5s0 -j REJECT
#XarxaA pot accedir al servei 2013 de totes les xarxes de internet excepte de la xarxa hisx2
iptables -A FORWARD -p tcp -s 172.21.0.0/16 -d 192.168.2.0/24 -p tcp -o enp5s0 --dport 2013 -j REJECT
iptables -A FORWARD -p tcp -d 172.21.0.0/16 -p tcp -o enp5s0 --dport 2013 -j ACCEPT
# Evitar que es fasilfiqui la ip Origen: SPOOFING
# Qualsevol paquet que arribi a br-69badb8e5ec8 que la ip origen no sigui 172.21.0.0/16 DROP
iptables -A FORWARD ! -s 172.21.0.0/16 -i br-69badb8e5ec8 -j DROP

#Exemple port forwading
#############################################################
# qui vulgui accedir al port 5001 el rediregeixes al host 172.21.0.2 al port 13
iptables -t nat -A PREROUTING -p tcp --dport 5001 -j DNAT --to 172.21.0.2:13
iptables -t nat -A PREROUTING -p tcp --dport 5002 -j DNAT --to 172.21.0.3:13
# qui vulgui accedir al port 5001 el rediregeixes al port 13
iptables -t nat -A PREROUTING -p tcp --dport 5003 -j DNAT --to :13
iptables -t nat -A PREROUTING -p tcp --dport 6001 -j DNAT --to 172.21.0.2:80
iptables -t nat -A PREROUTING -p tcp --dport 6002 -j DNAT --to 10.1.1.8:80
iptables -t nat -A PREROUTING -p tcp --dport 6000 -j DNAT --to :22
iptables -t nat -A PREROUTING -p tcp -s 192.168.2.35 --dport 6022 -j DNAT --to :22
iptables -t nat -A PREROUTING -p tcp -s 172.21.0.0/16 --dport 25 -j DNAT --to 192.168.2.56:25
iptables -t nat -A PREROUTING -p tcp -s 172.22.0.0/16 --dport 25 -j DNAT --to 192.168.2.56:25
iptables -t nat -A PREROUTING -p tcp -s 172.21.0.2 --dport 80 -j DNAT --to 192.168.2.56:80
iptables -t nat -A PREROUTING -p tcp -s 172.22.0.2 --dport 80 -j DNAT --to 192.168.2.56:80
