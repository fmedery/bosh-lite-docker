# bosh-lite-docker

## info
* Tested on Linux
* ```docker-ce``` needs to be installed
* ```sudo```, ```sed``` and ```tput``` (which are probably already installed) are also needed.
* You need to be able to run ```sudo``` commands
* your user needs to be part of the docker group:
```sh
sudo usermod -a -G docker ${USER}
```
* version 2 of bosh-cli needs to be installed: https://bosh.io/docs/cli-v2.html#install
* if ```bosh``` cli is called ```bosh2``` on your computer, you can replace the BOSH variable inside functions file or create a symlink:
```sh
sudo ln -s $(which bosh2) /usr/loca/bin/bosh
```
* **the script needs to be run at every reboot.**

## how to install bosh lite docker
* git clone this repository
* go into the folder created and run
```sh
./bootstrap.sh
```

## cleanup
* you can use ./cleanup.sh to remove all the files created

