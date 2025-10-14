# AVML Usage Guide

Version: AVML v0.14.0
https://github.com/microsoft/avml/releases/tag/v0.14.0

AVML, or Acquire Volatile Memory Linux, is a tool to acquire volatile memory from Linux based operating systems. 

The AVML binary is located within the Memory Capture/AVML directory of the USB drive.

The outputted .mem file can be several gigabytes in size, ensure enough space is present before proceeding.

## Step-by-step walkthrough

### Running directly on the device

1. run Command Prompt as administrator
2. in the command line, navigate to the appropriate directory using the cd command
(image)
3. write out the following command: sudo ./avml LinuxMemory.mem
(image)
the first term, sudo gives us permission to run the command.
the second term runs the avml script
the third term is the output files name. You can use any file name desired, as long as it 
ends with .mem
4. run the command and wait for it to complete. 
5. once the command finishes, in the same folder as the tool will be an outputted .mem file
containing the physical memory of the system
(image)

### Running from a mounted USB drive

1. ensure the avml file is renamed to avml.exe (as this will identify it as a file that can be executed)
2. ensure the usb drive is mounted. if it isn't, find the relevant heading in the troubleshooting section.
3. run the following command: sudo /lib64/ld-linux-x86-64.so.2 /(path)/(to)/(avml)/(file)/avml.exe LinuxMemory.mem (output file name)
4. wait for command to finish.
5. once the command finishes, in the same folder as the tool will be an outputted .mem file containing the captured memory.
(image)

If these steps are completed, a memory dumb of the systems volatile memory has been created for further investigation.

## Troubleshooting

Potentially, the avml file will lack the necessary permissions to be run.
In order to fix this, apply execute permissions to the file by running: chmod a+x
If the file is not run as sudo, the user may lack the permission needed to run the file instead. Ensure 
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