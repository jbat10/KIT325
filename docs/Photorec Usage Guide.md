
# Photorec Usage Guide


Version: TestDisk & PhotoRec 7.2
https://www.cgsecurity.org/wiki/TestDisk_Download

Photorec is a file carving tool used to acquire and restore deleted file remnants from linux and windows operatin systems. 

The files to run are located within the (path here) directory of the USB drive. 

An output directory is provided for the recovered files, located with the (path here) directory.

A script was not created for Photorec, as it was not seen as necessary. 

## Step-by-step walkthrough

### Linux Version

The tool can be run from the command line. Once the tool has been opened, the process for running is identical
to the windows version.

1. Open terminal and locate the "photorec_static" file within the linux section of the USB drive.
2. Run the tool with the command "./photorec_static"
3. this will display the tool within the terminal interface. See the corrosponding image under step 3 of the windows version walkthough.
4. Continue from step 4 of the windows version walkthrough.

### Windows Version

1. within the (path here) folder on the USB drive, locate the file "photorec_win.exe"
2. Right click the file and select "Run as Administrator"
3. A command prompt window will open with the instructions from the tool displayed.
![Photorec display](https://github.com/jbat10/KIT325/blob/main/docs/Images/photorecwin.PNG)
4. Select the drive partition you wish to search for, using arrow keys and enter to select.
5. Select the filesystem type of the drive. You can *usually* press enter straight away when this prompt appears.
6. Select whether all the space needs to be searched, or just unallocated space.
7. Select the directory to save the recovered files to. A directory is provided on the USB drive labelled OutputDir.
![Photorec Output](https://github.com/jbat10/KIT325/blob/main/docs/Images/photorecoutput.PNG)

If these steps are completed, restored files will be placed within the provided output directory on the USB drive and available for further investigation.


## Troubleshooting




