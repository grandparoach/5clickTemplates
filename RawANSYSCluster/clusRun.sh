#!/bin/bash
USER=$1
NAMES=`cat /home/$USER/bin/nodenames.txt` #names from names.txt file
echo "launching $2"
for NAME in $NAMES; do
  #the & here will fork off a run for each node and move to the next, the wait at the end waits until all is complete
  echo $NAME
  ssh -t $NAME $2
done
wait
echo "completed $2"
