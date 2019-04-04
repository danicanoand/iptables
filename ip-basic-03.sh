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


# Relges related established
###############################################
#permetre navegar web (mal feta)
 #iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
#iptables -A INPUT  -p tcp --sport 80 -j ACCEPT
#filtrant trafic nomes de resposta
 #iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
 #iptables -A INPUT  -p tcp --sport 80 -m tcp -m state \
 #	--state RELATED,ESTABLISHED -j ACCEPT
#oferiri el servei web i permetre nomes resposta a peticions establertes
 #iptables -A INPUT  -p tcp --dport 80 -j ACCEPT
 #iptables -A OUTPUT -p tcp --sport 80 -m tcp -m state \
 #       --state RELATED,ESTABLISHED -j ACCEPT
#oferiri el servei web a tothom excepte al i05 i permetre nomes resposta a peticions establertes
 #iptables -A INPUT  -p tcp --dport 80 -s 192.168.2.35 -j REJECT
 #iptables -A INPUT  -p tcp --dport 80 -j ACCEPT
 #iptables -A OUTPUT -p tcp --sport 80 -m tcp -m state \
 #       --state RELATED,ESTABLISHED -j ACCEPT

