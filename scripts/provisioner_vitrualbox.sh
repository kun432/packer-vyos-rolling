#!/bin/vbash

INSECKEY=`curl -L https://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub`
INSECKEY_TYPE=`echo ${INSECKEY} | awk '{print \$1}'`
INSECKEY_VALUE=`echo ${INSECKEY} | awk '{print \$2}'`
INSECKEY_NAME=`echo ${INSECKEY} | awk '{print \$3}'`

source /opt/vyatta/etc/functions/script-template

# Add Debian Jessie repository
set system package repository buster url 'http://ftp.jp.debian.org/debian/'
set system package repository buster distribution 'buster'
set system package repository buster components 'main contrib non-free'
set system package repository lithium url 'http://dev.packages.vyos.net/vyos/'
set system package repository lithium distribution 'current'
set system package repository lithium components 'main'
commit
save

# Install VBoxGuestAdditions
sudo apt-get update
sudo apt-get -y install linux-headers-4.4.47 build-essential dkms
sudo ln -sf /usr/src/linux-headers-4.4.47-amd64-vyos /lib/modules/4.4.47-amd64-vyos/build
sudo mkdir /media/VBoxGuestAdditions
sudo mount -o loop,ro VBoxGuestAdditions.iso /media/VBoxGuestAdditions
sudo sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run
sudo perl -p -i -e 's,^(#include\s+<iprt/asm.h>),#include <uapi/linux/pkt_cls.h>\r\n$1,' \
	/opt/VBoxGuestAdditions-5.0.40/src/vboxguest-5.0.40/vboxsf/utils.c
sudo /opt/VBoxGuestAdditions-5.0.40/init/vboxadd setup
rm VBoxGuestAdditions.iso
sudo umount /media/VBoxGuestAdditions
sudo rmdir /media/VBoxGuestAdditions

# Delete Debian Jessie repository
delete system package repository jessie
delete system package repository lithium
commit
save

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
