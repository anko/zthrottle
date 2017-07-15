#!/usr/bin/env zsh
( echo "1\n2\n3" ; sleep 2 ; echo "4\n5" ; sleep 5; echo "6" ) \
    | ./zthrottle 1
