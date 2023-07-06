#!/bin/bash

if [[ -z "$SWAP_PCT" ]]; then
    SWAP_PCT="0.7"
fi

function do_cgroup {
    docker_container=$(cat /proc/1/cgroup | sed 's/0::.\+\/\(.\+\)/\1/')
    cgpath=$(find /sys/fs/cgroup -type d -iname $docker_container)"/../"

    for f in "$cgpath"*/memory.swap.max; do
            echo "Setting cgroup: $f"
            fbase=$(dirname "$f")
            memlimit=$(cat "$fbase/memory.max")
            if [[ "$memlimit" != "max" ]]; then
                    if [[ "$SWAP_PCT_ALT" != "" ]]; then
                        memory_high=$(awk -vp=$memlimit 'BEGIN{printf "%d" , p*'$SWAP_PCT_ALT'}')
                        echo "$memory_high" > $fbase/memory.high
                    fi
                    memory_high=$(awk -vp=$memlimit 'BEGIN{printf "%d" , p*'$SWAP_PCT'}')
                    echo "$memory_high" > $fbase/memory.high
                    echo "max" > $fbase/memory.swap.max
            fi
    done
}

while [[ 1 ]]; do
    do_cgroup
    sleep 60
done