#!/bin/bash

CONFIG=$HOME/.config/kcminputrc
CURRENT=`kreadconfig5 --file $CONFIG --group Mouse --key XLbInptLeftHanded`

if [ $CURRENT = "true" ]; then
  kwriteconfig5 --file $CONFIG --group Mouse --key XLbInptLeftHanded false
elif [ $CURRENT = "false" ]; then
  kwriteconfig5 --file $CONFIG --group Mouse --key XLbInptLeftHanded true
fi

kcminit mouse
