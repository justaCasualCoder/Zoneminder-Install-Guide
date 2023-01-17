#!/bin/bash
if [ -z $cprt ]; then
export cprt=0
fi
if [ $cprt != 1 ]; then
echo --------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------
echo ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ Zoneminder Install Script ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎
echo ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ by @justaCasualCoder ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎
echo --------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------‎
echo ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎
echo ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎
echo ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎
fi
export cprt=1
DIR=$( pwd; )
USER=$(whoami)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
reset=$(tput sgr0)
echo $green "Please select your Linux-based operating system:"
echo $green "1. Fedora"
echo $green "2. CentOS 7 / Redhat"
echo $green "3. Ubuntu"
echo $green "4. Debian"
echo $green "5. Arch Linux"
until [ $choice -ge 1 ] && [ $choice -le 6 ]
do
echo $red "Now we are going to choose the OS " $reset
read -p "Enter the number corresponding to your operating system: " choice
case $choice in
  1)
    echo $green "You have selected Fedora." $reset
    OS=Fedora
    sudo chmod +x FedoraServerInstall.sh
    sudo ./FedoraServerInstall.sh
    ;;
  2)
    echo $green "You have selected CentOS 7 /Redhat ." $reset
    OS="Centos 7 / Redhat"
    sudo chmod +x RHEL-Centos7-installerzoneminder.sh
    sudo ./RHEL-Centos7-installerzoneminder.sh
    ;;
  3)
    echo $green "You have selected Ubuntu ." $reset
    OS="Ubuntu"
    sudo chmod +x ZoneminderUBUNTUSERVERINSTALL.sh
    sudo ./ZoneminderUBUNTUSERVERINSTALL.sh
    ;;
  4)
    echo $green "You have selected Debian ." $reset
    OS="Debian"
    sudo chmod +x DebianZoneminderInstaller.sh
    sudo ./DebianZoneminderInstaller.sh
    ;;
  5)
    echo $green "You have selected Arch Linux." $reset
    OS="Arch Linux"
    if [ $OS = 'Arch Linux' ];
then
sudo pacman -Qe | grep 'yay' &> /dev/null
if [ $? == 0 ]; then
   echo $Green Yay Is already installed!
else
sudo pacman -Syu
sudo pacman -S git --noconfirm
sudo pacman -S fakeroot --noconfirm
sudo pacman -S make --noconfirm
cd /opt
sudo git clone https://aur.archlinux.org/yay-git.git
sudo chown -R $USER:$USER ./yay-git
cd yay-git
makepkg -si --noconfirm
sudo chmod +x Arch\ Linux\ install.sh
sudo ./Arch\ Linux\ Install.sh
fi
fi
    ;;
  *)
    echo $red "Invalid selection. Please try again." $reset
    ;;
esac
done
export OS=$OS
