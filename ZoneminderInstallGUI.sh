#!/bin/bash
#!/usr/bin/env bash

menu=("Ubuntu" "Arch Linux" "Fedora" "Centos 7 / Redhat") 
answer=`zenity --list --column="Supported Systems" "${menu[@]}" --height 500 --width=500 --title="ZoneMinder System Selection"`

if [ "$answer" = "Ubuntu" ]; then
 echo placeholder  
fi
if [ "$answer" = "Arch Linux" ]; then
    echo placeholder
fi
if [ "$answer" = "Fedora" ]; then
    exec ./installzoneminderREDHATGENERAL.sh
fi
if [ "$answer" = "Centos 7 / Redhat" ]; then
    echo placeholder
fi
echo $answer
