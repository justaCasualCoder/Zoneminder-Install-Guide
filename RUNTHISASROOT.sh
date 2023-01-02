#!/bin/bash
# Check if machine is server or desktop
echo -n "Are you running this script on a Server or Desktop?  : "
read ServerorDesktop
while [ $ServerorDesktop != "Server" ] && [ $ServerorDesktop != "Desktop" ] ; do
  echo Invalid input. Please enter 'Server' or 'Desktop'
  read ServerorDesktop
done
# Check if an input parameter was provided
if [ $# -eq 1 ]; then
  # Use the input parameter as the message
  parameter=$1
fi
if [ $parameter = "-m"]; then
  if [ $ServerorDesktop = Server ]; then
  chmod +x OSPICKERSERVER.sh
  ./OSPICKERSERVER.sh
  exit 0
  else
    chmod +x ZoneminderInstallGUI.sh
  ./ZoneminderInstallGUI.sh
  exit 0
  fi
fi
sudo dnf install zenity
sudo apt-get -y install zenity
if [ $? != "1" ];
then
sudo yum -y install zenity
fi
if [ $? != "1" ];
then
sudo pacman -Sy --noconfirm
sudo pacman -S zenity --noconfirm
fi
export cprt=0
echo --------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------
echo ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ Zoneminder Install Script ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎
echo ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ by @justaCasualCoder ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎
echo --------------------------------------------------------------------------------
echo --------------------------------------------------------------------------------‎
echo ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎
echo ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎ ‎
echo ‎ ‎ ‎
‎‎‎FILE=`dirname $0`/license.txt
if [ $ServerorDesktop = "Server" ]; then
echo "Terms And Conditions are at https://github.com/justaCasualCoder/Zoneminder-InstallerGUI/blob/main/license.txt"
else
zenity --text-info \
   --title="License" \
   --filename=$FILE \
   --checkbox="I read and accept the terms."
fi
export cprt=1
DIR=$( pwd; )
USER=$(whoami)
Red=$'\e[1;31m'
Green=$(tput setaf 2)
if [ '$1'  =  '-m' ];
then
sudo ./ZoneminderInstallGUI.sh
sleep 1
exit 0
fi
if [ $? != "1" ];
then
sudo dnf install lsb_release
fi
sudo apt-get -y install lsb-release
if [ $? != "1" ];
then
sudo yum -y install lsb-release
fi
if [ $? != "1" ];
then
sudo pacman -Sy --noconfirm
sudo pacman -S lsb_release --noconfirm
fi

lsb_release -a | grep -qe buntu
if [ $? = "0" ];
then
OS=Ubuntu
fi
lsb_release -a | grep -qe Fedora
if [ $? = "0" ];
then
OS=Fedora
fi
if [ -f "/etc/SuSE-release" ]; then
OS=OpenSuSE
fi
lsb_release -a | grep -qe Arch
if [ $? = '0' ];
then
OS="Arch Linux"
fi
lsb_release -a | grep -qe Debian
if [ '$?' = "0" ];
then
OS=Debian
fi
if [ -z $OS ]
then
      echo $Red '!ERROR! Your OS could not be detected; the manual OS picker will start'
      if [ $ServerorDesktop = Server ]; then
      chmod +x OSPICKERSERVER.sh
      ./OSPICKERSERVER.sh
      else
      ./ZoneminderInstallGUI.sh
      fi
else
      echo  Your OS is $OS
fi
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
echo $OS
if [[ $OS = 'Ubuntu' ]]
then
    if [ $ServerorDesktop = "Server" ]; then

    sudo chmod +x ZoneminderUBUNTUSERVERINSTALL.sh
    sudo ./ZoneminderUBUNTUSERVERINSTALL.sh
    else
    sudo chmod +x UbuntuZoneminderGUIinstall.sh
    sudo ./UbuntuZoneminderGUIinstall.sh
    fi
fi
if [ $OS = 'Fedora' ]; then
    if [ $ServerorDesktop = "Server" ]; then
    sudo chmod +x FedoraServerInstall.sh
    sudo ./FedoraServerInstall.sh
    else
    sudo chmod +x installzoneminderREDHATGENERAL.sh
    sudo ./installzoneminderREDHATGENERAL.sh
fi
if [ $OS = "OpenSuSE" ]; then
    sudo chmod +x RHEL-Centos7-installerzoneminder.sh
    sudo ./RHEL-Centos7-installerzoneminder.sh
fi
if [ $OS = "Debian" ]; then
    sudo chmod +x DebianZoneminderInstaller.sh
    sudo ./DebianZoneminderInstaller.sh
fi
echo "You chose $OS as your OS"
fi
