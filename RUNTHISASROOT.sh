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
lsb_release -a | grep -qe Debian
if [ "$?" -eq "0" ];
then
OS=Debian
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
sudo chmod +x Arch\ Linux\ install.sh
sudo ./Arch\ Linux\ Install.sh  
fi
fi
if [ "$answer" = "Ubuntu" ]; then
    sudo chmod +x ZoneminderUBUNTUINSTALL.sh
    sudo ./ZoneminderUBUNTUINSTALL.sh
fi 
if [ "$answer" = "Fedora" ]; then
    sudo chmod +x installzoneminderREDHATGENERAL.sh
    sudo ./installzoneminderREDHATGENERAL.sh
fi
if [ "$answer" = "OpenSuSE" ]; then
    sudo chmod +x RHEL-Centos7-installerzoneminder.sh
    sudo ./RHEL-Centos7-installerzoneminder.sh
fi
if [ "$answer" = "Debian" ]; then
    sudo chmod +x DebianZoneminderInstaller.sh
    sudo ./DebianZoneminderInstaller.sh
fi
echo "You chose $answer as your OS"
