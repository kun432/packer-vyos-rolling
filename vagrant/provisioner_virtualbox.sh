#!/bin/vbash

INSECKEY=`curl -L -sS https://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub`
INSECKEY_TYPE=`echo ${INSECKEY} | awk '{print \$1}'`
INSECKEY_VALUE=`echo ${INSECKEY} | awk '{print \$2}'`
INSECKEY_NAME=`echo ${INSECKEY} | awk '{print \$3}'`

source /opt/vyatta/etc/functions/script-template

# Add Debian Jessie repository
echo "deb http://deb.debian.org/debian/ buster main" | sudo tee -a /etc/apt/sources.list
echo "deb http://security.debian.org/ buster/updates main" | sudo tee -a /etc/apt/sources.list
echo "deb http://dev.packages.vyos.net/repositories/current/ current main" | sudo tee -a /etc/apt/sources.list 

# Install VBoxGuestAdditions
LINUX_HEADERS=$(uname -r)
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y linux-headers-$LINUX_HEADERS build-essential dkms
sudo ln -sf /usr/src/linux-headers-${LINUX_HEADERS} /lib/modules/${LINUX_HEADERS}/build
pwd
ls -lta
cat .vbox_version
sudo mkdir /media/VBoxGuestAdditions
sudo mount -o loop,ro VBoxGuestAdditions_$(cat .vbox_version).iso /media/VBoxGuestAdditions
sudo sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run
sudo /opt/VBoxGuestAdditions-5.0.40/init/vboxadd setup
rm VBoxGuestAdditions_$(cat .vbox_version).iso
sudo umount /media/VBoxGuestAdditions
sudo rmdir /media/VBoxGuestAdditions

# Removing leftover leases and persistent rules
sudo rm -f /var/lib/dhcp3/*

# Removing apt caches
sudo rm -rf /var/cache/apt/*

# Removing hw-id
delete interfaces ethernet eth0 hw-id
commit
save

# 
set system login user vagrant authentication public-keys ${INSECKEY_NAME} type ${INSECKEY_TYPE}
set system login user vagrant authentication public-keys ${INSECKEY_NAME} key ${INSECKEY_VALUE}
commit
save
