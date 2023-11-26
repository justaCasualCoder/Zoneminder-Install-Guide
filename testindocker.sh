#!/bin/bash
# This script is used to test differant linux distros with my install script
Ubuntu() {
sudo docker run --rm -v $(pwd):$(pwd) -w $(pwd) -i ubuntu << EOF
apt update && apt install lsb-release python3 curl wget -y
wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py -O /bin/systemctl
chmod +x /bin/systemctl
echo "" >> /bin/apt-add-repository # Docker has Universe repo by default
echo y | DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC bash NewInstall.sh # Auto config TZdata, install packages with no comfirmation
curl -Ssf --keepalive-time 5 --write-out "%{http_code}" localhost/zm/ &> /dev/null # Try to make request
if [ $? != 0 ]; then
exit 1
else
exit 0
fi
EOF
if [ $? != 0 ]; then
echo "Ubuntu Failed!"
ubuntu=false
else
echo "Ubuntu is Working!"
ubuntu=true
fi
}
Alpine() {
sudo docker run --rm -v $(pwd):$(pwd) -w $(pwd) -i alpine << EOF
apk update && apk add wget curl bash openrc python3
mkdir -p /run/openrc/exclusive
touch /run/openrc/softlevel
openrc
echo y | TZ=Etc/UTC bash NewInstall.sh
curl -Ssf --keepalive-time 5 --write-out "%{http_code}" localhost/zm/ &> /dev/null
if [ $? != 0 ]; then
exit 1
else
exit 0
fi
EOF
if [ $? != 0 ]; then
echo "FAILED!"
alpine=false
else
echo "SUCCESS!"
alpine=true
fi
}
Debian() {
sudo docker run --rm -v $(pwd):$(pwd) -w $(pwd)  -i debian << EOF
apt update && apt install curl lsb-release python3 wget -y
wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py -O /bin/systemctl
chmod +x /bin/systemctl
echo y | DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC bash NewInstall.sh
curl -Ssf --keepalive-time 5 --write-out "%{http_code}" localhost/zm/ &> /dev/null
if [ $? != 0 ]; then
exit 1
else
exit 0
fi
EOF
if [ $? != 0 ]; then
echo "FAILED!"
debian=false
else
echo "SUCCESS!"
debian=true
fi
}
Fedora() {
sudo docker run --rm -v $(pwd):$(pwd) -w $(pwd) -i fedora << EOF
echo "assumeyes=1" >> /etc/dnf/dnf.conf
dnf update && dnf install lsb-release python3 curl wget e2fsprogs -y
wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py -O /bin/systemctl
chmod +x /bin/systemctl
echo y |  TZ=Etc/UTC bash NewInstall.sh docker # Auto config TZdata, install packages with no comfirmation , and pass docker flag to overwrite systemctl
curl -Ssfk --keepalive-time 5 --write-out "%{http_code}" https://localhost/zm/ &> /dev/null # Try to make request
if [ $? != 0 ]; then
exit 1
else
exit 0
fi
EOF
if [ $? != 0 ]; then
echo "FAILED!"
Fedora=false
else
echo "SUCCESS!"
Fedora=true
fi
}
Arch() {
docker run --rm -v $(pwd):$(pwd) -w $(pwd) -i archlinux << EOF
pacman-key --init
pacman -Syu python3 wget curl sudo --nocomfirm # Mask pacman command in future..
wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py -O /bin/systemctl
chmod +x /bin/systemctl
echo "root ALL=(ALL:ALL) ALL" >> /etc/sudoers
echo y |  TZ=Etc/UTC bash NewInstall.sh
EOF
}
opensuse() {
docker run --rm -v $(pwd):$(pwd) -w $(pwd) -i opensuse/tumbleweed << EOF
zypper --gpg-auto-import-keys refresh
zypper -n refresh
zypper -n install python3 wget curl sudo
wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py -O /bin/systemctl
chmod +x /bin/systemctl
echo "root ALL=(ALL:ALL) ALL" >> /etc/sudoers
echo y |  TZ=Etc/UTC bash NewInstall.sh docker
EOF
}
$1

