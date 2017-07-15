#!/usr/bin/env zsh
INTERVAL="$1"

CHILD_PID=

BUFFER=$(mktemp)
CAN_PRINT_IMMEDIATELY=1
CAN_START_SUBPROCESS=1

child-return () {
    CAN_START_SUBPROCESS=1
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
        if [[ -n $CAN_START_SUBPROCESS ]]; then
            CAN_START_SUBPROCESS=
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
