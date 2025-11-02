
# WinPmem Usage Guide

Version: Release 4.0 RC2
https://github.com/Velocidex/WinPmem/releases/tag/v4.0.rc1

WinPmem is a tool used to acquire a physical memory dump of windows operating systems. 

Both the x64 and x86 versions are included for each windows system type respectively. 

The size of the outputted .raw file will be rather large. Ensure enough space is present on the drive before proceeding.

WinPmem can be run from the master script. If this is desired, please use the Master Script usage guide instead. Below is a walkthrough on how to run the tool on the USB drive without the use of a script.

## Step-by-step walkthrough

The tool can be run from the command line.

1. run Command Prompt as administrator
2. in the command line, navigate to the /tools/windows directory.
3. write out the following command:

for x64 versions: winpmem_mini_x64_rc2.exe ../Output/WinPmem/physmem.raw

for x86 versions: winpmem_mini_x86.exe ../Output/WinPmem/physmem.raw

![WinPmem command normal](https://github.com/jbat10/KIT325/blob/main/docs/Images/winpmemnorm.PNG)

the second term in the command is the output files name and directory. You can use any file name desired,
as long as it ends with .raw
4. run the command and wait for it to complete. This can take several minutes.
5. once the command finishes, in the same folder as the tool will be an outputted .raw file
containing the physical memory of the system.

![WinPmem ouput](https://github.com/jbat10/KIT325/blob/main/docs/Images/winpmemoutput.PNG)

If these steps are completed, a physically memory dump has been acquired for further investigation.



