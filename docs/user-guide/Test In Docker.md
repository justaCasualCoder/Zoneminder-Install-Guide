# Testing in Docker
Currently in development, there is a script called `testindocker.sh`. The goal of this is to test multiple distros with the install script. It checks if localhost/zm connects and determines if Zoneminder is working or not. The final goal of this is to have it check nightly using GitHub actions.
Distro support for docker test script:

- [ ] Alpine Linux
- [ ] Arch Linux
- [x] Ubuntu Linux
- [ ] Android ( [Termux](https://termux.dev/) Debian Proot - [My Install Scripts](https://github.com/justaCasualCoder/Zoneminder-Termux) )
- [x] Debian Linux
- [x] Fedora Linux
- [ ] OpenSuSE TumbleWeed


Example running it (Have docker installed!):

```
./testindocker.sh Ubuntu
```
