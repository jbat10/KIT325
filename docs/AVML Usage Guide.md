# AVML Usage Guide

Version: AVML v0.14.0
https://github.com/microsoft/avml/releases/tag/v0.14.0

AVML, or Acquire Volatile Memory Linux, is a tool to acquire volatile memory from Linux based operating systems. 

The AVML binary is located within the /ScriptsAndTools directory of the USB drive.

The outputted .mem file can be several gigabytes in size, ensure enough space is present before proceeding.

AVML can be run from the master script. If this is desired, please use the Master Script usage guide instead. Below is a walkthrough on how to run the tool on the USB drive without the use of a script.

## Step-by-step walkthrough

1. run Command Prompt as administrator
2. in the command line, navigate to the avml binary directory using the cd command
3. ensure the avml file is renamed to avml.exe (this will identify it as a file that can be executed)
4. ensure the usb drive is mounted. if it isn't, find the relevant heading in the troubleshooting section.
5. run the following command: sudo /lib64/ld-linux-x86-64.so.2 ./avml.exe ../Output/AVML/LinuxMemory.mem (output file name and directory)

![WinPmem command normal](https://github.com/jbat10/KIT325/blob/main/docs/Images/commandToRunAVML.PNG)

6. wait for the command to finish.
7. once the command finishes, in the output/avml directory, a .mem file containing the captured memory should be present.

If these steps are completed, a memory dumb of the systems volatile memory has been created for further investigation.

## Troubleshooting

If the file is not run as sudo, the user will lack the permission needed to run the file. Ensure 
sudo is present at the start of the command.

### Mounting a USB drive

If your device has not automatically mounted when plugged in.
1. find the name of the drive by running: "sudo fdisk -l". 
2. In the output, locate your device. It will generally be /dev/sdb or /dev/sdb1.
3. from her, create a mount destination. An empty directory will suffice
4. run the command: "sudo mount /dev/sdb (name of drive) /media/usb (mount point directory)
5. The device has now been mounted. use this pathway when executing avml from the drive.


### Finding mounted device path

Mounted devices are usually found within the /media pathway. You can run the command: cat /proc/mounts to find the pathway of this device. 



## References

help with mounting USB drive: https://askubuntu.com/questions/37767/how-to-access-a-usb-flash-drive-from-the-terminal 