#!/usr/bin/env zsh
INTERVAL="$1"

CHILD_PID=

BUFFER=$(mktemp)
ALLOWED=1
IN_FLIGHT=

child-return () {
    IN_FLIGHT=
    ALLOWED=1
}
trap child-return CHLD

cleanup () {
    kill -TERM "$CHILD_PID" &> /dev/null
    rm -rf "$TMP"
    exit
}
trap cleanup TERM INT QUIT

while read LINE; do
    #echo "buffering $LINE"
    echo "$LINE" >> $BUFFER
    #echo "buffer"
    #cat $BUFFER
    if [[ -n $ALLOWED ]]; then
        #echo "immed"
        echo $LINE
        ALLOWED=
    else
        if [[ -z $IN_FLIGHT ]]; then
            #echo "starting"
            IN_FLIGHT=1
            (
                sleep $INTERVAL
                #echo "hi"
                tail -n1 $BUFFER
                echo -n '' > $BUFFER
            ) &
            CHILD_PID=$!
        fi
    fi
done
if [[ -n $CHILD_PID ]]; then
    wait $CHILD_PID &> /dev/null
    cleanup
fi
