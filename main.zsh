#!/usr/bin/env zsh
INTERVAL="$1"

CHILD_PID=

TMP=$(mktemp --directory)
BUFFER="$TMP/buffer"
ALLOWED_MARKER="$TMP/allowed"
echo "1" > $ALLOWED_MARKER
IN_FLIGHT_MARKER="$TMP/in-flight"
echo -n '' > $IN_FLIGHT_MARKER

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
    if [[ -s $ALLOWED_MARKER ]]; then
        #echo "immed"
        echo $LINE
        echo -n '' > $ALLOWED_MARKER
    else
        if [[ ! -s $IN_FLIGHT_MARKER ]]; then
            #echo "starting"
            echo "1" > $IN_FLIGHT_MARKER
            (
                sleep $INTERVAL
                #echo "hi"
                tail -n1 $BUFFER
                echo -n '' > $BUFFER
                echo 1 > $ALLOWED_MARKER
                echo -n '' > $IN_FLIGHT_MARKER
            ) &
            CHILD_PID=$!
        fi
    fi
done
if [[ -n $CHILD_PID ]]; then
    wait $CHILD_PID &> /dev/null
    cleanup
fi
