#!/bin/bash

OUR_PID="$$"

function do_rdns {
    cgpath=$(cat /proc/$OUR_PID/cgroup | sed 's/0::\/..\/..\/../\/sys\/fs\/cgroup\/kubepods/')"/../"
    echo "$cgpath"

    for f in "$cgpath"*/memory.swap.max; do
            fbase=$(dirname "$f")
            memlimit=$(cat "$fbase/memory.max")
            if [[ "$memlimit" != "max" ]]; then
                    echo "memory.max: $memlimit"
                    memory_high=$(awk -vp=$memlimit 'BEGIN{printf "%d" , p*0.7}')
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