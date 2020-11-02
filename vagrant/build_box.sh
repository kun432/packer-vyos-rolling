#!/bin/bash

SCRIPT_PATH=`realpath $0`
SCRIPT_BASE=`dirname ${SCRIPT_PATH}`
BASE_DIR="${SCRIPT_BASE}/.."
cd ${BASE_DIR} || exit 1

export ISO_IMAGE="$(ls -t iso/*.iso | head -1)"
export VERSION="$(echo $ISO_IMAGE | xargs basename | awk -F'-' '{ print $2 "-" $3 "-" $4 }')"
export ISO_SHA256_SUM="$(ls -t iso/*.iso.sha256 | head -1 | xargs cat | awk '{ print $1 }')"
export PACKER_CACHE_DIR="vagrant/packer_cache"
export PACKER_BUILD_DIR="vagrant/packer_build"
export PACKER_LOG_PATH="vagrant/packer_build.log"
export PACKER_LOG=1
export BOX_DIR="${BASE_DIR}/box"

echo "ISO: $ISO_IMAGE"
echo "SUM: $ISO_SHA256_SUM"
echo "VER: $VERSION"

rm -rf ${PACKER_BUILD_DIR}

packer build -only=virtualbox vagrant/packer.json

cp vagrant/metadata.json vagrant/Vagrantfile ${PACKER_BUILD_DIR}/
cd ${PACKER_BUILD_DIR}
mv vyos.ovf box.ovf
tar cf ${BOX_DIR}/vyos.box box.ovf vyos-disk001.vmdk Vagrantfile metadata.json
cd ${BASE_DIR}

cat <<EOF | tee ${BOX_DIR}/vyos.json
{
  "name": "kun432/vyos",
  "description": "vyos rolling release vagrant box for virtualbox",
  "versions": [
    {
      "version": "${VERSION}",
      "providers": [
        {
          "name": "virtualbox",
          "url": "${BOX_DIR}/vyos.box"
        }
      ]
    }
  ]
}
EOF

if vagrant box list | grep '^kun432/vyos '
then
	vagrant box remove --all -f kun432/vyos
fi
vagrant box add --name kun432/vyos ${BOX_DIR}/vyos.json