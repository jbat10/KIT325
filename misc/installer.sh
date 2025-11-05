#!/bin/bash

rootdisk=`findmnt -n -o SOURCE /`

if [ -f .kit325 ] ; then
	echo "Installer has already run."
	exit
fi

if [ "`echo $rootdisk | cut -b 1-7`" = "/dev/sd" ] ; then
	target="`echo $rootdisk | cut -b 1-8`"
	(echo n; echo 3; echo ""; echo ""; echo t; echo 3; echo 11; echo w;) | sudo fdisk $target
	target+="3"
	sudo mkfs.exfat -n Toolkit $target
	fstab="`sudo blkid | grep $target | cut -d " " -f 2 | sed 's/"//g'` /home/investigator/Toolkit exfat defaults,relatime,uid=1000,gid=1000 0 0"
	echo $fstab | sudo tee -a /etc/fstab
	sudo systemctl daemon-reload

	sudo mount -a
	cd /home/investigator/Toolkit
	git clone https://github.com/jbat10/KIT325 .
	bash downloader.sh

	cd /home/investigator
	touch .kit325
	echo "Installation Complete."
else
	echo "Unknown disk type. Please install on a flash drive."
fi
