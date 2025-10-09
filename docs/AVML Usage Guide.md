# AVML Usage Guide

Version: AVML v0.14.0
https://github.com/microsoft/avml/releases/tag/v0.14.0

AVML, or Acquire Volatile Memory Linux, is a tool to acquire volatile memory from Linux based operating systems. 
The AVML binary is located within the Memory Capture/AVML directory of the USB drive.
The outputted .mem file can be several gigabytes in size, ensure enough space is present before proceeding.


did a test run of AVML, got it working

## Step-by-step walkthrough


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
5. once the command finishes, in the same folder as the tool will be an outputted .raw file
containing the physical memory of the system
(image)


If these steps are completed, a memory dumb of the systems volatile memory has been created for further investigation.

## Troubleshooting

Potentially, the avml file will like the necessary permissions to be run.
In order to fix this, apply execute permissions to the file by running: chmod a+x
If the file is not run as sudo, the user may lack the permission needed to run the file instead. Ensure 
sudo is present at the start of the command.
