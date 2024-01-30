#!/bin/bash

source ./restart.config

# get running screen id if exist
screenidPal=$(screen -list | awk '{print $1}' | awk '/.Pal$/{print $1}' | cut -d "." -f 1)

# set RCON command
info="info"
save="save"
showplayers="showplayers"
shutd="Shutdown $shutdt"
brdc="Broadcast we'll-back-in[$(date -d "+$rest seconds" "+%Y-%m-%d|%H:%M:%S")]"

# get mem info
if [ $useSwap == 1 ];then
    meml=$( free -g | awk 'NR==3{print $4}' )
else
    meml=$( free -g | awk 'NR==2{print $4}' )
fi

doStart () {
    # create a new screen
    screen -dmS Pal
    # get new screenid
    screenidn=$(screen -list | awk '{print $1}' | awk '/.Pal$/{print $1}' | cut -d "." -f 1)
    # cd to PalServer dictory
    screen -x -S $screenidn -p 0 -X stuff "cd $ServerPath\n"
    # start the server
    screen -x -S $screenidn -p 0 -X stuff "./PalServer.sh\n"
    echo "[$(date "+%Y-%m-%d|%H:%M:%S")]Server start at screenID $screenidn." >> restart.log
    echo "[$(date "+%Y-%m-%d|%H:%M:%S")]------" >> restart.log
}

doRestart () {
    $RCONPath -H$HOST -P$PORT -p"$password" "$save"
    $RCONPath -H$HOST -P$PORT -p"$password" "$shutd"
    $RCONPath -H$HOST -P$PORT -p"$password" "$brdc"
    echo "[$(date "+%Y-%m-%d|%H:%M:%S")]waiting for the server to shut down..." >> restart.log
    sleep "$rest"
    echo "[$(date "+%Y-%m-%d|%H:%M:%S")]start the server..." >> restart.log
    # terminate the old screen
    screen -R $screenidPal -X quit
    # create a new screen
    screen -dmS Pal
    # get new screenid
    screenidn=$(screen -list | awk 'NR==2{print $1}' | awk '/.Pal$/{print $1}' | cut -d "." -f 1)
    # cd to PalServer dictory
    screen -x -S $screenidn -p 0 -X stuff "cd $ServerPath\n"
    # start the server
    screen -x -S $screenidn -p 0 -X stuff "./PalServer.sh\n"
    echo "[$(date "+%Y-%m-%d|%H:%M:%S")]Server restart at screenID $screenidn." >> restart.log
    echo "[$(date "+%Y-%m-%d|%H:%M:%S")]------" >> restart.log
}

if [ ! $screenidPal ];then
    echo "[$(date "+%Y-%m-%d|%H:%M:%S")]There's no PalServer running, start now..." >> restart.log
    doStart
else
    if [[ $($RCONPath -H$HOST -P$PORT -p"$password" "$info" | awk '{print $1}') == "Welcome" ]];then
        echo "[$(date "+%Y-%m-%d|%H:%M:%S")]server running..." >> restart.log
        echo "[$(date "+%Y-%m-%d|%H:%M:%S")]$($RCONPath -H$HOST -P$PORT -p"$password" "showplayers")" >> restart.log
        if [ $meml -le $resf ];then
            echo "[$(date "+%Y-%m-%d|%H:%M:%S")]too heavy, start restarting the server..." >> restart.log
            doRestart
        else
            echo "[$(date "+%Y-%m-%d|%H:%M:%S")]${meml} memory left." >> restart.log
            echo "[$(date "+%Y-%m-%d|%H:%M:%S")]------" >> restart.log
        fi
    else
        echo "[$(date "+%Y-%m-%d|%H:%M:%S")]no running server found in screen $screenidPal.Pal." >> restart.log
        echo "[$(date "+%Y-%m-%d|%H:%M:%S")]Please kill screen $screenidPal.Pal, and run this script to start the server." >> restart.log
        echo "[$(date "+%Y-%m-%d|%H:%M:%S")]------" >> restart.log
    fi
fi
