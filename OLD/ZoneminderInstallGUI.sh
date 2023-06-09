#!/bin/bash
#!/usr/bin/env bash
if [ -z $cprt ]; then
export cprt=0
fi
if [ $cprt != 1 ]; then
echo --------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------
echo     Zoneminder Install Script          
echo         by @justaCasualCoder     
echo --------------------------------------------------------------------------------
echo -------------------------------------------------------------------------------- 
echo                                       
echo                
echo                
fi
export cprt=1
DIR=$( pwd | cut -c2- )
menu=("Ubuntu" "Arch Linux" "Fedora" "Centos 7 / Redhat" "Debian") 
answer=`zenity --list --column="Supported Systems" "${menu[@]}" --height 500 --width=500 --title="ZoneMinder System Selection"`

if [ "$answer" = "Arch Linux" ]; then
sudo chmod +x Arch\ Linux\ install.sh
sudo ./Arch\ Linux\ Install.sh
fi
if [ "$answer" = "Ubuntu" ]; then
    sudo chmod +x $DIR/UbuntuZoneminderGUIinstall.sh
    sudo ./$DIR/ZoneminderUBUNTUINSTALL.sh
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
