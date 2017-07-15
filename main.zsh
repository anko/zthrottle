#!/usr/bin/env zsh
interval () {
    zmodload zsh/system
    zmodload zsh/zselect

    NEXT_ALLOWED_PRINT_TIME=0
    NEXT=
    INTERVAL="$*"
    while true; do
        if zselect -t 0 0; then
            sysread -t 0 -s 1
            STATUS=$?
            case $STATUS in
                5)
                    if [[ -z $NEXT ]]; then
                        exit
                    fi
                    ;;
                0)
                    read LINE
                    NEXT="$REPLY$LINE"
                    ;;
            esac
        fi
        if [[ -n $NEXT ]] && (( $(epoch now) >= $NEXT_ALLOWED_PRINT_TIME )); then
            print $NEXT
            NEXT=
            NEXT_ALLOWED_PRINT_TIME="$(epoch now + $INTERVAL)"
        fi
    done
}

( echo "1\n2\n3" ; sleep 2 ; echo "4" ) \
    | interval 2 seconds
