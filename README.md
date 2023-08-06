# Zoneminder Install Script
This repository contains a script to install Zoneminder and a [LAMP](https://en.wikipedia.org/wiki/LAMP_(software_bundle)) Stack on the following linux distributions - 
- Alpine Linux
- Arch Linux
- Ubuntu Linux
- Android ( [Termux](https://termux.dev/) Debian Proot - [My Install Scripts](https://github.com/justaCasualCoder/Zoneminder-Termux) )
- Debian Linux
- Fedora Linux
- OpenSuSE TumbleWeed
- Most other systems using Docker

Currently the most stable distro to install on is : **Debian**

If you would like a support for a Linux distro , create a issue and i will try to add support!

## Docker
Docker is now working - it is a very early image based on Debian - you can use it by running
```
docker run -d ghcr.io/justacasualcoder/zoneminder-installerscript:main
```
It will start Apache2 Mariadb and Zoneminder inside the container
