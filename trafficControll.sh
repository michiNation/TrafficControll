#!/bin/bash


function show_usage {
    echo ""
    echo "You have to configure all the needed settings: "
    echo "DL -> Download"
    echo "UL -> Upload"
    echo "We need speed in kb/s, delay in ms,jitter in ms, packet loss in % and queue size"
    echo ""
    echo "============================================== "
    echo "sudo ./trafficControll.sh <1. DL-Speed> <2. DL-Delay> <3. DL-Jitter> <4. DL-PacketLoss> <5. DL-QueueSize> <6. UL-Speed> <7. UL-Delay> <8. UL-Jitter>  <9. UL-PacketLoss> <10. UL-QueueSize> <11. Device>"
    echo "============================================== "
    echo ""
    echo ""
    echo "You can also delete or show existing settings"
    echo "============================================== "
    echo ""
    echo "Example: sudo ./trafficControll 2000 100 0 0 1000 3000 0 0 0 1000 eth0s3"
    echo "Example: sudo ./trafficControll.sh delete eth0s3"
    echo "Example: sudo ./trafficControll.sh show eth0s3"
    echo ""
    echo ""
    echo "Autor: MG"
}

if [ $# -eq 0 ]; then
    show_usage $0
    exit 0
fi

if [ $1 = "delete" ]; then
    echo "Delete all settings."
    tc qdisc del dev $2 root 
    tc qdisc del dev $2 ingress 
    tc qdisc del dev $2 root
    tc qdisc del dev $2 ingress
    tc qdisc del dev ifb1 root
    ip link set dev ifb1 down
     ip link delete ifb1 type ifb
    exit 0
fi

if [ $1 = "show" ]; then
    echo "Delete all settings."
    tc -s qdisc show dev $2
    exit 0
fi

if ([ $2 -eq 0 ] && [ $3 -ne 0 ])
        then echo "CAN'T SET JITTER WITHOUT DELAY"
  exit 2
fi

echo " ===== Setup Traffic Limitations for device ${11} ====="
echo " "
echo " "
echo " ===== Setup Download ====="
echo "Set Download Speed limitation to: $1kbit"
echo "Set Download Delay to: $2.0ms"
echo "Set Jitter to: $3.0ms"
echo "Set Download Packet loss to: $4"

#Prepare the routing to set download rates
sudo modprobe ifb
sudo ip link add ifb1 type ifb
sudo ip link set dev ifb1 up
sudo tc qdisc add dev ${11} ingress
sudo tc filter add dev ${11} parent ffff: protocol ip u32 match u32 0 0 flowid 1: action mirred egress redirect dev ifb1
sudo tc qdisc add dev ifb1 root handle 1: htb default 1
sudo tc class add dev ifb1 parent 1: classid 1:1 htb rate 32000000.0kbit
#Set speed
sudo tc class add dev ifb1 parent 1: classid 1:129 htb rate $1.0Kbit ceil $1.0Kbit
#Set delay, jitter, loss and queue size is requested
if [ $5 -ne 0 ]; then
    echo "Set Download Queue size: $5"
    tc qdisc add dev ifb1 parent 1:129 handle 2a2b: netem loss $4.0% delay $2.0ms $3.0ms distribution normal limit $5
else
    echo "No Download Queue size set"
    tc qdisc add dev ifb1 parent 1:129 handle 2a2b: netem loss $4.0% delay $2.0ms $3.0ms
fi
#add the filter to route the packages though the settings
sudo tc filter add dev ifb1 protocol ip parent 1: prio 2 u32 match ip dst 0.0.0.0/0 match ip src 0.0.0.0/0 flowid 1:129

echo " "
echo " "
echo " ===== Setup Upload ====="
echo "Set Upload Speed limitation to: $6kbit"
echo "Set Upload Delay to: $7"
echo "Set Upload Jitter to: $8"
echo "Set Upload Packet loss to: $9"
  
sudo tc qdisc add dev ${11} root handle 2: htb default 1
sudo tc class add dev ${11} parent 2: classid 2:1 htb rate 10000000.0kbit
sudo tc class add dev ${11} parent 2: classid 2:83 htb rate $6.0Kbit ceil $6.0Kbit

if [ $5 -ne 0 ]; then
    echo "Set Download Queue size: $10 "
    tc qdisc add dev ${11} parent 2:83 handle 2a2b: netem loss $9.0% delay $7.0ms $8.0ms distribution normal limit ${10}
else
    echo "No Download Queue size set"
    tc qdisc add dev ${11} parent 2:83 handle 2a2b: netem loss $9.0% delay $7.0ms $8.0ms
fi
tc filter add dev ${11} protocol ip parent 2: prio 2 u32 match ip dst 0.0.0.0/0 match ip src 0.0.0.0/0 flowid 2:83
echo "Setup done"