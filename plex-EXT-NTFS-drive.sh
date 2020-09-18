#!/bin/bash 
#Author: New Wavex86 
#Date Created: Wed 09 Sep 2020
#Script to remount an EXT or NTFS drive to work on plex rpi server
#Automated some instructions from this guide: //forums.plex.tv/t/using-ext-ntfs-or-other-format-drives-internal-or-external-on-linux/198544

DRIVE_CHECK=0 #Variable for while loop, while user enters drive path



#Check if root
if [ $EUID -eq 0 ];
then
	echo "You are root!, running script"
	sleep 1
else
	echo "Script must be run as root!"
	exit 2
fi

#Getting NTFS isntalled
apt install ntfs-3g

echo "Now printing out your Drives"
lsblk
sleep 2

#Make sure user doesn't enter /, or blkid won't work
while [ $DRIVE_CHECK -eq 0 ];
do
	read -p "Please enter the full drive path in the dev folder: " Blk

	if [[ $Blk =~ $/ ]];  
	then 
		echo " Please don't enter /, at the end of drive path, restarting"

	else

		DRIVE_CHECK=1 ;; #End loop, user entered properly

	fi

done

UUID=$( blkid $Blk | awk ' { print $6 } '| cut -c 7-22 )
TYPE=$( blkid $Blk | awk ' { print $7 } ' | cut -c 7-10  ) #Get drive format, luckily ext4 and ntfs 
							#are both 5 characters long

#Unmount drive
umount $Blk


echo "Will now create a folder in the mnt directory for the plex drive to be mounted"
read -p "Do you want to specify a different directory[Y/n] " REPLY
if [[ $REPLY =~ [y-Y] ]];
then
	read -p "Enter drive mount path here: " DRIVE_PATH
	mkdir ${DRIVE_PATH}/plexmediaserver
	echo "UUID=${UUID}       ${DRIVE_PATH}/plex/  $TYPE   defaults,auto,rw,nofail 0 1" >> /etc/fstab
	
	#Mount Drive
	mount ${DRIVE_PATH}/plex

	#Change file permissions
	#find ${DRIVE_PATH}/plex -type d -exec chmod 755 {} \;

	#find ${DRIVE_PATH}/plex -type f -exec chmod 644 {} \; #Root can read and read, others only read
else
	mkdir /mnt/plex/
	echo "UUID=${UUID}       /mnt/plex/  $TYPE   defaults,auto,rw,nofail 0 1" >> /etc/fstab
	
	#Mount Drive
	mount /mnt/plex/

	#Change file permissions
	#find ${DRIVE_PATH}/plex -type d -exec chmod 755 {} \;

	#find ${DRIVE_PATH}/plex -type f -exec chmod 644 {} \; #Root can read and write, others only read
	

		
fi

echo "The drive is now mounted in the /mnt directory!"

exit 0 
