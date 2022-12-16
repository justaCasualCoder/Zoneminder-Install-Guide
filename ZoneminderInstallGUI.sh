#!/bin/bash
#!/usr/bin/env bash

menu=("Ubuntu" "Arch Linux" "Fedora" "Centos 7 / Redhat" "Debian") 
answer=`zenity --list --column="Supported Systems" "${menu[@]}" --height 500 --width=500 --title="ZoneMinder System Selection"`

if [ "$answer" = "Arch Linux" ]; then
 echo placeholder  
fi
if [ "$answer" = "Ubuntu" ]; then
    echo ./ZoneminderUBUNTUINSTALL.sh
fi
if [ "$answer" = "Fedora" ]; then
    sudo ./installzoneminderREDHATGENERAL.sh
fi
if [ "$answer" = "Centos 7 / Redhat" ]; then
    echo placeholder
fi
if [ "$answer" = "Debian" ]; then
    sudo ./DebianZoneminderInstaller.sh
fi
echo "You chose $answer as your OS"
