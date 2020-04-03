#/bin/bash
seq 0 3 | xargs -l1 -I@ compton -CGb -d :0.@
