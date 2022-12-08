#!/bin/bash

echo "1.script to display al arguments"
COUNT=1
while [[ $# -gt 0 ]];do
  echo "Argument $COUNT = $1"
  COUNT=$((COUNT + 1))
  shift    
done
echo "Count=${COUNT}"

echo $1