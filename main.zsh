#!/usr/bin/env zsh
INTERVAL="$1"

CHILD_PID=

BUFFER=$(mktemp)
CAN_PRINT_IMMEDIATELY=1
IN_FLIGHT=

child-return () {
    IN_FLIGHT=
    CAN_PRINT_IMMEDIATELY=1
}
trap child-return CHLD

cleanup () {
    kill -TERM "$CHILD_PID" &> /dev/null
    rm -rf "$TMP"
    exit
}
trap cleanup TERM INT QUIT

while read LINE; do
    echo "$LINE" >> $BUFFER
    if [[ -n $CAN_PRINT_IMMEDIATELY ]]; then
        echo $LINE
        CAN_PRINT_IMMEDIATELY=
    else
        if [[ -z $IN_FLIGHT ]]; then
            IN_FLIGHT=1
            (
                sleep $INTERVAL
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
