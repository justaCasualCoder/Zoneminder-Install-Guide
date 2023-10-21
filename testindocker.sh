#!/bin/bash
# This script is used to test differant linux distros with my install script
Ubuntu() {
sudo docker run --rm -v $(pwd):$(pwd) -w $(pwd) -i ubuntu << EOF
apt update && apt install lsb-release -y
cp fakesystemctl /bin/systemctl
chmod +x /bin/systemctl
echo "" >> /bin/apt-add-repository
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
ubuntu=false
else
echo "SUCCESS!"
ubuntu=true
fi
}
Alpine() {
sudo docker run --rm -v $(pwd):$(pwd) -w $(pwd) -i alpine << EOF
cp fakesystemctl /bin/systemctl
chmod +x /bin/systemctl
apk add bash openrc
mkdir -p /run/openrc/exclusive
touch /run/openrc/softlevel
openrc
echo y | TZ=Etc/UTC bash NewInstall.sh
apk add curl
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
sudo docker run --rm -v $(pwd):$(pwd) -w $(pwd) -i debian << EOF
apt update && apt install curl -y
cp fakesystemctl /bin/systemctl
chmod +x /bin/systemctl
# echo y | DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC bash NewInstall.sh
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
Debian

