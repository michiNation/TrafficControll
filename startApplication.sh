#!/bin/bash
# ./../AsyncTcpEcho/build/TcpProg 127.0.0.1 5050 server
#Usage: ./binary 127.0.0.1 5050 server
#Usage: ./binary 127.0.0.1 5050 client <modeNr> <loops>
#Modes for Client: KEYBOARD = 0;STARTFIRECLOSE = 1;STARTLOOPCLOSE = 2;STARTDOWNLOADCLOSE = 3;STARTFIREDOWNLOADCLOSE = 4

exec ./../AsyncTcpEcho/build/TcpProg 127.0.0.1 5050 client 2 5