# bosh-lite-docker


## Requirements
* It only has been tested on Linux only.
* You need to be able to run sudo.
* Docker needs to be install and the user running the script needs to be part of the docker group
```sh
sudo usermod -a -G docker ${USER}
```
* version 2 of bosh-cli needs to be installed: 
https://bosh.io/docs/cli-v2.html#install
* sudo, sed and tput (which are probably already installed) are also needed.
* if bosh cli is called bosh2 on your computer, you can replace the BOSH variable inside the file functions

## how to install bosh lite docker
* git clone this repository
* go to the repository
run 
```sh
./bootstrap.sh
```