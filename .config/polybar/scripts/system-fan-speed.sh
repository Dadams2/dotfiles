#!/usr/bin/env bash

speed=$(sensors | grep fan3 | awk '{print $2; exit}')

if [ "$speed" != "" ]; then
  echo "$speed"
else
  echo ""
fi
