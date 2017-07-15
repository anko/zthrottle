#!/usr/bin/env zsh
# Lets a line pass only once every $1 seconds.  If multiple lines arrive during
# the cooldown interval, only the latest is passed on when the cooldown ends.

INTERVAL="$1"

CHILD_PID=
BUFFER=$(mktemp)
CAN_PRINT_IMMEDIATELY=1
CAN_START_SUBPROCESS=1

# Reset state when child process returns
child-return () {
    CAN_START_SUBPROCESS=1
    CAN_PRINT_IMMEDIATELY=1
}
trap child-return CHLD

# Clean up when quitting
cleanup () {
    kill -TERM "$CHILD_PID" &> /dev/null
    rm "$BUFFER"
    exit
}
trap cleanup TERM INT QUIT

while read LINE; do
    # If we're just starting, just print immediately
    if [[ -n $CAN_PRINT_IMMEDIATELY ]]; then
        echo $LINE
        CAN_PRINT_IMMEDIATELY=
    else
        # Otherwise, store the line for later
        echo "$LINE" > $BUFFER
        # And spawn a subprocess to handle it one interval later, unless one is
        # already running.  With the SIGCHLD trap, the state variables will
        # reset when it exits.
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

# Once we exhaust stdin, wait for the last child process to finish, if any.
if [[ -n $CHILD_PID ]]; then
    wait $CHILD_PID &> /dev/null
    cleanup
fi
