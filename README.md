# packer-vyos-rolling

build Vagrant virtualbox box for VyOS-1.3 rolling release via Packer.
## Usage

Clone this repositry.

```
$ git clone https://github.com/kun432/packer-vyos-rolling
$ cd packer-vyos-rolling
```

Download ISO and checksum from https://downloads.vyos.io/?dir=rolling/current/amd64. Put those into `iso` directory.

build.

```
$ ./vagrant/build_box.sh
```

Create a Vagrantfile.

```
Vagrant.configure("2") do |config|
  config.vagrant.plugins = ["vagrant-vyos"]
  config.vm.box = "kun432/vyos"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.network "private_network", ip: "192.168.34.10"
end
```

Start your VM.

```
$ vagrant up
```