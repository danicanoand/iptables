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



#exemples de regles OUTPUT
########################################
#accedir a qualsevol destí port/destí
 #iptables -A OUTPUT  -j ACCEPT
#accedir port 13 de quasevol destí
 #iptables -A OUTPUT -p tcp --dport 13 -j ACCEPT
 #iptables -A OUTPUT -p tcp --dport 13 -d 0.0.0.0/0 -j ACCEPT
#accedir al port 1013 de qualsevol destí excepte del i05
 #iptables -A OUTPUT -p tcp --dport 2013 -d 192.168.2.35 -j REJECT
 #iptables -A OUTPUT -p tcp --dport 2013 -j ACCEPT
#denegat accedir a qualsevol port 3013 pero si al i05
 #iptables -A OUTPUT -p tcp --dport 3013 -d 192.168.2.35 -j ACCEPT
 #iptables -A OUTPUT -p tcp --dport 3013 -j REJECT
#accedir a tothom, tancat a la clase i obert a i05 del port 4013
 #iptables -A OUTPUT -p tcp --dport 4013 -d 192.168.2.35 -j ACCEPT
 #iptables -A OUTPUT -p tcp --dport 4013 -d 192.168.2.0/24 -j REJECT
 #iptables -A OUTPUT -p tcp --dport 4013 -j ACCEPT
#denegar acces als ports 80,13,7
 #iptables -A OUTPUT -p tcp --dport 80 -j REJECT
 #iptables -A OUTPUT -p tcp --dport 13 -j REJECT
 #iptables -A OUTPUT -p tcp --dport 7 -j REJECT
#no permetre accedir al host i06,i05
 #iptables -A OUTPUT -p tcp  -d 192.168.2.35 -j REJECT
 #iptables -A OUTPUT -p tcp  -d 192.168.2.36 -j REJECT
#no podem accedir ni a la clase de 1er ni a la de 2on
 #iptables -A OUTPUT -p tcp  -d 192.168.2.0/24 -j REJECT
 #iptables -A OUTPUT -p tcp  -d 192.168.1.0/24 -j REJECT
#a la xarxa hisx2 no es permet accedir excepte per ssh
#iptables -A OUTPUT -p tcp --dport 22 -d 192.168.2.0/24 -j ACCEPT
#iptables -A OUTPUT -p tcp  -d 192.168.2.0/24 -j REJECT
