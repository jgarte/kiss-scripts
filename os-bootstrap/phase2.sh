#!/bin/sh -e

### Set version variables

scriptversion="1.1"


### Virtual Machine check

Make=$(cat /sys/class/dmi/id/sys_vendor 2> /dev/null) 

if [ "$Make" = "QEMU" ]

then

   echo "Machine is a VM - $Make"

   IsVM="true"

elif [ "$Make" = "VMware" ]

then

   echo "Machine is a VM - $Make"

   IsVM="true"

else

   echo "Machine is not a VM - $Make"

   IsVM="false"

fi


### Set compile flags

export CFLAGS="-O3 -pipe -march=native"
export CXXFLAGS="-O3 -pipe -march=native"
export MAKEFLAGS="-j$(nproc)"


### Build/install gpg

for pkg in gnupg1; do
  echo | kiss build $pkg
  kiss install $pkg
done


### Add/configure kiss repo key

gpg --keyserver keys.gnupg.net --recv-key 46D62DD9F1DE636E
echo trusted-key 0x46d62dd9f1de636e >>/root/.gnupg/gpg.conf

cd /var/db/kiss/repo
git config merge.verifySignatures true


### Update kiss

echo | kiss update
echo | kiss update


### Recompile installed apps

echo | kiss build $(ls /var/db/kiss/installed)


### Build/Install base apps

for pkg in e2fsprogs dosfstools util-linux eudev dhcpcd libelf ncurses perl tzdata acpid openssh sudo; do
  echo | kiss build $pkg
  kiss install $pkg
done


if [ "$IsVM" != "true" ]

then

   for pkg in wpa_supplicant; do
   echo | kiss build $pkg
   kiss install $pkg
   done

fi

cd /root
