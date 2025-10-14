
# WinPmem Usage Guide

!!!STILL NEED TO SHOW HOW TO LOCATE USB DIRECTORY, AS IS NOT ON C: DRIVE!!!
!!!STILL NEED TO FIGURE OUT HOW TO OUTPUT THE FILE INTO DIFFERENT DIRECTORY!!!
!!!SAME WITH AVML!!!

Version: Release 4.0 RC2
https://github.com/Velocidex/WinPmem/releases/tag/v4.0.rc1

WinPmem is a tool used to acquire a physical memory dump of windows operating systems. 

The WinPmem binaries are located within the Memory Capture/WinPmem directory of the USB drive. 

Both the x64 and x86 versions are included for each windows system type respectively. 

The size of the outputted .raw file will be rather large. Ensure enough space is present on the drive before proceeding.

## Step-by-step walkthrough

The tool can be run from the command line.

1. run Command Prompt as administrator
2. in the command line, navigate to the appropriate directory using the cd command
(image)
3. write out the following command
for x64 versions: winpmem_mini_x64_rc2.exe physmem.raw
for x86 versions: winpmem_mini_x86.exe physmem.raw
(image)
the second term in the command is the output files name. You can use any file name desired,
as long as it ends with .raw
4. run the command and wait for it to complete. This can take several minutes.
5. once the command finishes, in the same folder as the tool will be an outputted .raw file
containing the physical memory of the system
(image)

The process for running this tool on a USB drive is identical to on the device itself. No changes to the method are necessary. 

If these steps are completed, a physically memory dump has been acquired for further investigation.


## Troubleshooting




