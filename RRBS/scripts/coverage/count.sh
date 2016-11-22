#!/bin/bash

awk 'BEGIN{count=0}{if($3>0){count+=1}}END{print count}' $1 > $2

echo "Finished on $HOSTNAME"
