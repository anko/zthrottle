#!/usr/bin/env zsh
# Lets a line pass only once every $1 seconds.  If multiple lines arrive during
# the cooldown interval, only the latest is passed on when the cooldown ends.

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
    rm "$BUFFER"
    exit
}
trap cleanup TERM INT QUIT

# Possible states:
#
# - CAN_PRINT_IMMEDIATELY == 1, CAN_START_SUBPROCESS == 1
#     -> print immediately
#
# - CAN_PRINT_IMMEDIATELY == 0, CAN_START_SUBPROCESS == 1
#     -> buffer the line; start a subprocess to handle it
#
# - CAN_PRINT_IMMEDIATELY == 0, CAN_START_SUBPROCESS == 0
#     -> buffer the line; let the in-flight subprocess handle it
#
# The state of (CAN_PRINT_IMMEDIATELY == 1, CAN_START_SUBPROCESS == 0) should
# never happen.
while read LINE; do
    if [[ -n $CAN_PRINT_IMMEDIATELY ]]; then
        echo $LINE
        CAN_PRINT_IMMEDIATELY=
    else
        echo "$LINE" > $BUFFER
        if [[ -n $CAN_START_SUBPROCESS ]]; then
            CAN_START_SUBPROCESS=
            (
                sleep $INTERVAL
                tail -n1 $BUFFER
            ) &
            CHILD_PID=$!
        fi
    fi
done
if [[ -n $CHILD_PID ]]; then
    wait $CHILD_PID &> /dev/null
    cleanup
fi
