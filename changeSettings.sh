#!/bin/bash

#can be used to change the settings already set from trafficControll

function show_usage {
    echo ""
    echo "THIS SHOULD ONLY BE USED AFTER trafficConroll is set"
    echo "It will CHANGE the settings if some have exist"
    echo ""
    echo ""
    echo "DL -> Download"
    echo "UL -> Upload"
    echo ""
    echo ""
    echo "============================================== "
    echo "sudo ./trafficControll.sh <1. DL-Speed> <2. DL-Delay> <3. DL-Jitter> <4. DL-PacketLoss> <5. DL-QueueSize> <6. UL-Speed> <7. UL-Delay> <8. UL-Jitter>  <9. UL-PacketLoss> <10. UL-QueueSize> <11. Device>"
    echo "============================================== "
    echo "Example: sudo ./changeSettings.sh 2000 100 0 0 1000 3000 0 0 0 1000 eth0s3"
    echo ""
    echo "Autor: MG"
    echo ""
}

if [ $# -eq 0 ]; then
    show_usage $0
    exit 0
fi
echo "DL Speed $1"
echo ""
tc class change dev ifb1 parent 1: classid 1:129 htb rate $1.0Kbit ceil $1.0Kbit
#Set delay, jitter, loss and queue size is requested
if [ $5 -ne 0 ]; then
    echo "Set Download Queue size: $5"
    tc qdisc change dev ifb1 parent 1:129 handle 2a2b: netem loss $4.0% delay $2.0ms $3.0ms distribution normal limit $5
else
    echo "No Download Queue size set"
    tc qdisc change dev ifb1 parent 1:129 handle 2a2b: netem loss $4.0% delay $2.0ms $3.0ms
fi

tc class change dev ${11} parent 2: classid 2:83 htb rate $6.0Kbit ceil $6.0Kbit
if [ $5 -ne 0 ]; then
    echo "Set Download Queue size: ${10} "
    tc qdisc change dev ${11} parent 2:83 handle 2a2b: netem loss $9.0% delay $7.0ms $8.0ms distribution normal limit ${10}
else
    echo "No Download Queue size set"
    tc qdisc change dev ${11} parent 2:83 handle 2a2b: netem loss $9.0% delay $7.0ms $8.0ms
fi
echo "Setup done"