#!/bin/bash

#source: https://www.elektronik-kompendium.de/sites/kom/0910141.htm

#uses trafficControll to set the Usecase 2G, 3G or 4G
#and uses the changeSettings to simulate a handover

packetLoss=0

function show_usage {
    echo ""
    echo "It will start the trafficContoll script and set the settings for 2G, 3G or 4G"
    echo "Can simulate a handover 2G -> 4G"
    echo "Can simulate a network outage 2G off 2G"
    echo "============================================== "
    echo "Example: sudo ./useCaseHandler.sh enp0s3 2G to 3G"
    echo "Example: sudo ./useCaseHandler.sh enp0s3 2G"
    echo "Example: sudo ./useCaseHandler.sh enp0s3 2G off"
    echo ""
    echo ""
    echo "Autor: MG"
}
# <1. DL-Speed> <2. DL-Delay> <3. DL-Jitter> <4. DL-PacketLoss> <5. DL-QueueSize> <6. UL-Speed> <7. UL-Delay> <8. UL-Jitter>  <9. UL-PacketLoss> <10. UL-QueueSize> <11. Device>"
 
function Start_Client {
    #./startLoopApplication.sh &
    echo "hello"
}

function Start_2G_Usecase {
    #2G DL 236,8 kbits Upload 118,4 kbits Latenz 350ms Jitter 50ms
    #echo "Example: sudo ./trafficControll 2000 100 0 0 1000 3000 0 0 0 1000 eth0s3"
    #echo "Example: sudo ./trafficControll.sh delete eth0s3"
    echo "Only 2G $1 $2 $3 $#"
    ./trafficControll.sh delete $1
    ./trafficControll.sh 236 175 25 $packetLoss 0 118 175 25 $packetLoss 0 $1  
}

function Start_3G_Usecase {
    #3G UMTS 384 kbits 128 kbits 180ms 10ms jitter
    echo "Only 3G "
    ./trafficControll.sh delete $1
    ./trafficControll.sh 384 90 5 $packetLoss 0 128 80 5 $packetLoss 0 $1  
}

function Start_4G_Usecase {
    #4G LTE 300 000 kbits 75 000 kbits 15ms jitter 5ms
    echo "Only 4G "
    ./trafficControll.sh delete $1
    ./trafficControll.sh 300000 8 5 $packetLoss 0 75000 8 5 $packetLoss 0 $1
}

function Start_5G_Usecase {
    #5G 20 000 000 kbits 10 000 000 000 kbits 2ms jitter 2ms
    echo "Only 4G "
    ./trafficControll.sh delete $1
    ./trafficControll.sh 20000000000 2 2 $packetLoss 0 10000000 2 2 $packetLoss 0 $1
}


function Change_to_2G_Usecase {
    #2G DL 236,8 kbits Upload 118,4 kbits Latenz 350ms Jitter 50ms
    #echo "Example: sudo ./trafficControll 2000 100 0 0 1000 3000 0 0 0 1000 eth0s3"
    #echo "Example: sudo ./trafficControll.sh delete eth0s3"
    echo "Only 2G "
    ./changeSettings.sh 236 175 25 $packetLoss 0 118 175 25 $packetLoss 0 $1  
}

function Change_to_3G_Usecase {
    #3G UMTS 384 kbits 128 kbits 180ms 10ms jitter
    echo "Only 3G "
    ./changeSettings.sh 384 90 5 $packetLoss 0 128 80 5 $packetLoss 0 $1  
}

function Change_to_4G_Usecase {
    #4G LTE 300 000 kbits 75 000 kbits 15ms jitter 5ms
    echo "Only 4G "
    ./changeSettings.sh 300000 8 5 $packetLoss 0 75000 8 5 $packetLoss 0 $1
}

function Change_to_NoNetwork_Usecase {
    #4G LTE 300 000 kbits 75 000 kbits 15ms jitter 5ms
    echo "Only 4G "
    ./changeSettings.sh 0 8 5 $packetLoss 0 0 8 5 $packetLoss 0 $1
}

function Do_Sleep {
   sleep 5
}

function Do_Sleep2 {
   sleep 2
}

function Do_Quick_Sleep {
   sleep 1
}

if [ $# -eq 0 ]; then
    show_usage $0
    exit 0
fi

echo "Use Device $1"
echo ""
echo "Setup the Usecase"
echo ""

if [ $# -eq 2 ]; then
    if [ $2 = "2G" ]; then
        Start_2G_Usecase $1
    elif [ $2 = "3G" ]; then
        Start_3G_Usecase $1 
    elif [ $2 = "4G" ]; then
        Start_4G_Usecase $1
    elif [ $2 = "5G" ]; then
        Start_5G_Usecase $1
    fi
  exit 0
fi

if ([[ $2 = "2G" ]] && [[ $3 = "to" ]]); then 
    if [ $4 = "3G" ]; then
        echo "Start 2G -> 3G Handoverusecase"
        Start_2G_Usecase $1
        Start_Client
        Do_Sleep
        Change_to_3G_Usecase $1
    elif [ $4 = "4G" ]; then
        echo "Start 2G -> 4G Handoverusecase"
        Start_2G_Usecase $1
        Start_Client
        Do_Sleep
        Change_to_4G_Usecase $1
    fi
elif ([[ $2 = "3G" ]] && [[ $3 = "to" ]]); then
    if [ $4 = "2G" ]; then
        echo "Start 3G -> 2G Handoverusecase"
        Start_3G_Usecase $1
        Start_Client
        Do_Sleep
        Change_to_2G_Usecase $1
    elif [ $4 = "4G" ]; then
        echo "Start 3G -> 4G Handoverusecase"
        Start_3G_Usecase $1
        Start_Client
        Do_Sleep
        Change_to_4G_Usecase $1
    fi
elif ([[ $2 = "4G" ]] && [[ $3 = "to" ]]); then
    if [ $4 = "2G" ]; then
        echo "Start 4G -> 2G -> 4G Usecase"
        Start_4G_Usecase $1
        Start_Client
        Do_Sleep2
        Change_to_2G_Usecase $1
        Do_Sleep2
        Change_to_4G_Usecase $1
    elif [ $4 = "3G" ]; then
        echo "Start 4G -> 3G Handoverusecase"
        Start_4G_Usecase $1
        Start_Client
        echo "sleep"
        Do_Sleep2
        echo "change"
        Change_to_3G_Usecase $1
    fi
elif ([[ $3 = "off" ]]); then
    if [ $# -eq 2 ]; then
        if [ $2 = "2G" ]; then
            Start_2G_Usecase $1
            Start_Client
            Do_Quick_Sleep
            Change_to_NoNetwork_Usecase $1
            Do_Quick_Sleep
            Change_to_2G_Usecase $1
        elif [ $2 = "3G" ]; then
            Start_3G_Usecase $1 
            Start_Client
            Do_Quick_Sleep
            Change_to_NoNetwork_Usecase $1
            Change_to_3G_Usecase $1
        elif [ $2 = "4G" ]; then
            Start_4G_Usecase $1
            Start_Client
            Do_Quick_Sleep
            Change_to_NoNetwork_Usecase $1
            Do_Quick_Sleep
            Change_to_4G_Usecase $1
        fi
    fi
fi
echo "Exit"