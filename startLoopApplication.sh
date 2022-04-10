#!/bin/bash
#exec ./../AsyncTcpEcho/build/TcpProg 127.0.0.1 5050 client 2 50
for (( i=0; i < 50; i++))
do
    #echo "start app $i"

    #Usecase with Loop for Handover
    #./../AsyncQuicEcho/build/AsyncQuic 192.168.7.2 5051 client 2 1 50
    #exec ./../AsyncTcpEcho/build/TcpProg 127.0.0.1 5050 client 2 50
    #Usecase with connect send and disconnect with Handover
    ./../AsyncQuicEcho/build/AsyncQuic 192.168.7.2 5051 client 1 1 1
    #./../AsyncTcpEcho/build/TcpProg 127.0.0.1 5050 client 1 1
done