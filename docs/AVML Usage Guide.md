# AVML Usage Guide

Version: AVML v0.14.0
https://github.com/microsoft/avml/releases/tag/v0.14.0

AVML, or Acquire Volatile Memory Linux, is a tool to acquire volatile memory from Linux based operating systems. 

The outputted .mem file can be several gigabytes in size, ensure enough space is present before proceeding.

AVML can be run from the master script. If this is desired, please use the Master Script usage guide instead. Below is a walkthrough on how to run the tool on the USB drive without the use of a script.

## Step-by-step walkthrough

1. run Command Prompt as administrator
2. in the command line, navigate to the avml binary directory using the cd command (within the tools directory)
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
