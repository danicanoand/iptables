# Confguració

## Router
Engegar normalment
ip a a 172.209.0.1/16 dev enp5s0
ip a
ip r
* Aquesta la faig al script
	echo 1 > /proc/sys/net/ipv4/ip_forward 

## ClientA
Iniciar el sistema en mode 1
ip link set lo up
ip link set enp5s0 up
ip a a 172.209.0.2/16 dev enp5s0
ip r a default via 172.209.0.1
ip a
ip r

## ClientB
Iniciar el sistema en mode 1
ip link set lo up
ip link set enp5s0 up
ip a a 172.209.0.3/16 dev enp5s0
ip r a default via 172.209.0.1
ip a
ip r


### Pruebas
Router: ping 172.209.0.2
Router: ping 172.209.0.3

ClientA: ping 172.209.0.1
ClientA: ping 172.209.0.3
ClientA: ping 192.168.2.52

ClientB: ping 192.168.2.52
ClientB: ping 172.209.0.1
ClientB: ping 172.209.0.2
