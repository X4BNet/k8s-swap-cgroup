#!/bin/bash

if [[ -z "$SWAP_PCT" ]]; then
    SWAP_PCT="0.7"
fi

function do_cgroup {
    docker_container=$(cat /proc/1/cgroup | sed 's/0::.\+\/\(.\+\)/\1/')
    if [[ -z "$docker_container" ]]; then
            echo "Could not determine container group base"
            return
    fi

    cgpath=$(find /sys/fs/cgroup -type d -iname $docker_container)"/../"
    if [[ ! -d "$cgpath" ]]; then
            echo "Cgroup path not found for $docker_container"
            return
    fi

    for f in "$cgpath"*/memory.swap.max; do
            fbase=$(dirname "$f")
            echo "Setting cgroup: $fbase"
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