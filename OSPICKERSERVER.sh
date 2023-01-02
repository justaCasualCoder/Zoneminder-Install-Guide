#!/bin/bash
DIR=$( pwd; )
USER=$(whoami)
Red=$'\e[1;31m'
Green=$(tput setaf 2)
echo $Green "Please select your Linux-based operating system:"
echo $Green "1. Fedora"
echo $Green "2. CentOS 7 / Redhat"
echo $Green "3. Ubuntu"
echo $Green "4. Debian"
echo $Green "5. Arch Linux"
until [ $choice -ge 1 ] && [ $choice -le 6 ]
do
echo $Red "Now we are going to choose the OS" 
read -p "Enter the number corresponding to your operating system: " choice

case $choice in
  1)
    echo $Green "You have selected Fedora."
    OS=Fedora
    ;;
  2)
    echo $Green "You have selected CentOS 7 /Redhat ."
    OS="Centos 7 / Redhat"
    ;;
  3)
    echo $Green "You have selected Ubuntu ."
    OS="Ubuntu"
    ;;
  4)
    echo $Green "You have selected Debian ."
    OS="Debian"
    ;;
  5)
    echo $Green "You have selected Arch Linux."
    OS="Arch Linux"
    ;;
  *)
    echo $Red "Invalid selection. Please try again."
    ;;
esac
done
export OS=$OS
