#!/bin/bash
#!/usr/bin/env bash

menu=("Ubuntu" "Arch Linux" "Fedora" "Centos 7 / Redhat" "Debian") 
answer=`zenity --list --column="Supported Systems" "${menu[@]}" --height 500 --width=500 --title="ZoneMinder System Selection"`

if [ "$answer" = "Arch Linux" ]; then
 echo placeholder  
fi
if [ "$answer" = "Ubuntu" ]; then
    sudo chmod +x ZoneminderUBUNTUINSTALL.sh
    sudo ./ZoneminderUBUNTUINSTALL.sh
fi 
if [ "$answer" = "Fedora" ]; then
    sudo chmod +x installzoneminderREDHATGENERAL.sh
    sudo ./installzoneminderREDHATGENERAL.sh
fi
if [ "$answer" = "Centos 7 / Redhat" ]; then
    sudo chmod +x RHEL-Centos7-installerzoneminder.sh
    sudo ./RHEL-Centos7-installerzoneminder.sh
fi
if [ "$answer" = "Debian" ]; then
    sudo chmod +x DebianZoneminderInstaller.sh
    sudo ./DebianZoneminderInstaller.sh
fi
echo "You chose $answer as your OS"
