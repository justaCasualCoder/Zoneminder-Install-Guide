#!/bin/bash
sudo apt-get -y install lsb-release
if [ "$?" != "1" ];
then
sudo yum -y install lsb-release
fi
lsb_release -a | grep -qe buntu
if [ "$?" -eq "0" ];
then 
OS=Ubuntu
fi
lsb_release -a | grep -qe Fedora
if [ "$?" -eq "0" ];
then 
OS=Fedora
fi
if [ -f "/etc/SuSE-release" ]; then
OS=OpenSuSE
fi
lsb_release -a | grep -qe Arch
if [ "$?" -eq "0" ];
then 
OS="Arch Linux"
fi
if [ -z "$OS" ]
then
      echo "Your OS could not be detected; the manual GUI OS picker will start"
      ./ZoneminderInstallGUI.sh
else
      echo  Your OS is $OS
fi
exit 0
if [ "OS" -eq "Arch Linux" ];
then
sudo pacman -Qe | grep 'yay' &> /dev/null
if [ $? == 0 ]; then
   echo "Yay Is already installed!"
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
fi
fi
