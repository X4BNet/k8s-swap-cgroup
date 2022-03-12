#!/bin/bash

if [[ -z "$SWAP_PCT" ]]; then
    SWAP_PCT="0.7"
fi

function do_cgroup {
    docker_container=$(cat /proc/1/cgroup | sed 's/0::\/..\///')
    echo "docker container: $docker_container"
    cgpath=$(find /sys/fs/cgroup -type d -iname $docker_container)"/../"
    echo "cgroup path: $cgpath"

    for f in "$cgpath"*/memory.swap.max; do
            fbase=$(dirname "$f")
            memlimit=$(cat "$fbase/memory.max")
            if [[ "$memlimit" != "max" ]]; then
                    echo "memory.max: $memlimit"
                    memory_high=$(awk -vp=$memlimit 'BEGIN{printf "%d" , p*'$SWAP_PCT'}')
                    echo "memory.high: $memory_high"
                    echo "$memory_high" > $fbase/memory.high
                    echo "max" > $fbase/memory.swap.max
            fi
    done
}

while [[ 1 ]]; do
    do_cgroup
    sleep 300
done