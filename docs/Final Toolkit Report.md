
# Final Report KIT325 Assignment Task 3


## Brief Introduction

The goal of this project was to create a lightweight, portable forensics toolkit situated on a USB storage device. When defining the scope, we decided to base the toolkit around being acquisition focused, designed to capture evidence in the field and bring it to a larger workstation for further dissemination. For this scope, we outlined the core functionality we needed from tools, being memory capture, disk imaging, registry analysis, file carving, and file acquisition. We also decided on having the toolkit be hybrid focused, with hot and cold tools for both linux and windows systems, requiring us to also create a Linux distro environment for the coldboot side of the drive. This report highlights the finer details of the project, explaining tool selection, testing results in regards to the SPDA document, usability observations, limitations, and future recommendations for the created toolkit.

## Rationale for Tool Selection


### WinPmem and AVML

WinPmem and AVML were selected as our memory capturing tools for Windows and Linux systems. AVML was chosen as it stood out as a commercially available and simple to use tool that would suit the needs of the toolkit perfectly, being capturing memory from Linux systems, and outputting it in a suitable file format. Whilst many other options could also have been suitable, AVML was the first selected and passed all tests set for it, so there was no need to trial others. WinPmem on the other hand, was almost the exact opposite. We went to great lengths to find a windows memory capturing tool that was specifically available for commercial use. A great many tools were considered, but could not be used primarily because of licensing concerns, such as FTK Imager, MAGNET RAM, FEX Memory Imager and more. This left us with WinPmem as essentially the only resulting tool we could find so far, however it looked to be suitable for the needs of the toolkit, even if it outputs the resulting memory file in the .raw format.

### Photorec

Photorec was chosen as our designated file carving option for a few key reasons. Firstly, whilst looking around for available options, Photorec appeared to be the standard choice, and commonly appeared amongst the options. It is also an open source tool, letting us use it without licensing concern in this project, and is already an ingest module integrated into autopsy, another tool we plan on using. When looked further into, the tool seemed sufficiently capable for our needs, and worked on both windows and linux operating systems. As such, we chose it to be tested first as our file carving tool. 

### NTFSTools and dd

NTFSTools was selected as the Windows file acquisition tool due to its ability to directly access NTFS filesystem structures at a low level, including the Master File Table (MFT), alternate data streams, and deleted file recovery. Its open-source nature and comprehensive feature set made it ideal for extracting individual files and system artifacts without mounting drives, which is crucial for forensic integrity.

For Linux systems, dd was chosen as the standard disk imaging tool due to its universal availability, reliability, and simplicity. As a core Unix utility, dd provides bit-for-bit copying of drives and partitions without requiring additional installations. Combined with standard Linux tools, it offers robust capabilities for both full disk imaging and individual file acquisition across various filesystem types.

### System Information Collection Scripts

Rather than relying on third-party tools, custom system information collection scripts were developed for both Windows and Linux environments. This approach was chosen to provide quick and comprehensive evidence gathering when time with the target system is limited. The scripts automate the collection of essential system context including running processes, network connections, user accounts, services, installed software, and hardware information. By creating a purpose-built solution, we ensured the toolkit could rapidly gather critical forensic context without dependencies on external tools, making it ideal for time-sensitive field acquisitions where understanding the system state is crucial for proper evidence interpretation.

## Testing Results

### Main Menu Script
The main scripts were written for both platforms and are able to be used across a wide range of systems. Both platforms detected whether administrator privileges were active or not and displayed appropriate warnings when run without elevated rights. All six menu options were tested, with each option successfully launching its corresponding tool and returning to the main menu upon completion.  

### Memory Capture Tools

Our testing criteria for the memory capturing tools involved two main tests to pass. The first was successful usage of the tool without any issues. In this regard, both WinPmem and AVML managed to produce .raw and .mem files of their systems memory with little difficulty. A virtual machine for Linux was used to test AVML as I lacked access to a Linux device, however AVML still performed as expected in this environment. 

The second main test involved successfully operating the tools from and storing the outputted memory files on a mounted USB drive. As I lack access to larger USB drives at the moment of testing, a 4gb USB was used, and the tools were only checked to have started creating a memory file instead of creating a full size file. For this test, WinPmem worked without issue, successfully running on and creating an output file on a USB drive, up until the drive ran out of space. AVML however had initial complications, specifically around execute permissions being different between the linux system and the window’s like formatting of the drive. With some troubleshooting and work arounds, we found a way to get the tool working again. By changing the avml file to avml.exe, the drive recognises it as an executable and gives it permission to be run as such. Adding the dynamic linker (/lib64/ld-linux-x86-64.so.2) to the command was also necessary to ensure the executable functioned correctly. With these changes, AVML was also able to create a .mem file of captured image up until again, the drive ran out of storage. 

A final test was included based on a suggestion from the second progress meeting. This test includes checking that the outputted .mem and .raw files are actually readable by memory analysis tools, and are useful for further examination. For this test, volatility 3 was used to examine the files from both avml and winpmem. When running a simple windows.info check on both the .mem and .raw files, the tool correctly read and displayed information on the contents of these memory files, showing that they were suitable for use.

### Photorec

From the SPDA document, the main testing criteria for Photorec is for the tool to be able to reconstruct files from unallocated space that match the contents of their original version. Whilst doing this, I also opted to ensure the tool works without issue on both windows and linux systems and when operating from a USB drive instead of the system itself. For the first test, a sample text file was created with an identifiable size and with easily recognisable contents. Once deleted, Photorec was able to recover the file and match it’s original content on both systems without issue, matching the files length and contents.
![Photorec Test Passed](./Images/PhotorecReportWin.PNG)
![Photorec Test Passed](./Images/PhotorecReportLin.PNG)
*Above are the successfully recovered files from Photorec*

For the second test, these results largely mirror the memory capture tools with their outcomes. The windows version functioned without issue from the USB drive, however the linux version needed extra modification to work without issue. 

### dd and NTFSTools

The file acquisition tools were tested on both Windows and Linux systems to verify their ability to extract and/or recover files from the system, while preserving metadata and generating initial forensic field reports. On Windows, the script was tested using ntfstools to extract system registry files from a test volume, successfully retrieving the files with complete metadata documentation, including timestamps, extraction paths in separate output directories. The MFT analysis feature was validated by dumping the master file table to CSV format, which accurately catalogued file entries, though ntfstools occasionally exhibited limitations detecting all files on the volume that were confirmed to exist through Windows Explorer. The undelete function successfully recovered a previously deleted test image by its inode number, with content intact, though some files could not be recovered, suggesting ntfstools may have incomplete coverage of the file system. On Linux, dd was used to create disk images successfully, with automatic MD5/SHA256 hash generation for integrity verification. The individual file extraction feature was validated by copying a test directory containing various file types, with rsync successfully preserving all timestamps and other metadata. File system analysis collected essential information into a report, such as directory structure, file types and key large files. Overall, both tools demonstrated core functionality for file acquisition and analysis, though ntfstools showed some limitations in file detection and recovery coverage on Windows volumes.

### Bootable Linux Environment

The bootable OS included in the toolkit was able to boot on real hardware. Secure boot did not need to be deactivated. By default, no non-toolkit partitions are mounted within the bootable OS, as Guymager and Autopsy are both capable of functioning on block devices, preventing accidental alteration of data on the target machine. Non-toolkit partitions *may* be mounted by the user if necessary, but as doing this is out-of-scope for the toolkit's intended operations it is left up to the user to act appropriately.

### Guymager and Autopsy

In testing the bootable environment, Guymager was able to create a dd image of a USB flash drive, which was then able to be opened and browsed in Autopsy as a data source. matching the original drive. This demonstrates that both tools are functional as installed in the toolkit, and satisfies the test case in the SPDA document. It was noted that attempting to create and open an E01 image would cause Autopsy to crash; Due to the opaqueness and complexity of the resulting crash log the cause of this could not be determined or resolved, however given the portable toolkit is unlikely to be used to analyse disk image files, only create images or analyse original disks, this is considered a minor issue.

![guymager done imaging](./Images/guymagercomplete.png)

![autopsy opening guymager image](./Images/autopsyopen.png)

### Distribution

After flashing the raw disk image of the bootable environment to a suitable USB drive using Balena Etcher, the toolkit could be booted. The installer script was able to create a new, labelled ExFAT partition in the remaining space on the drive containing this git repo, and the downloader script successfully downloaded and unpacked all remaining tools into their respective folders. This is verifiable by viewing the partition layout with the "lsblk" command on Linux or the Windows Partition Viewer, and inspecting the folder structure to verify all expected files are present. After an initial install on a USB 2.0 drive it was discovered that such a drive is too slow to properly operate a graphical desktop environment; A note was added to the README clarifying minimum drive specifications.

![partition layout after install](./Images/partitions.png)

![files after download](./Images/postinstall.png)

### Scripting

Scripting is a large component of the toolkit, intended to streamline the use of tools and provide an easy and simple interface for users to use the toolkit from. We created several wrapper scripts for each of the individual tools, as well as a master script (one for each Linux and Windows respectively) to call upon these scripts, letting all the evidence acquisition be done from this one interface point. This script also handles the output of the tools, providing subdirectories for each tool and timestamps to help categorise and sort evidence. 

A checksum hashing script was also made to generate hashes of the output files, saving them in a stored sha256 file alongside them. With was done so the integrity of these files can be verified, and is called whenever the main script attempts to exit on either versions. 

## Packaging Decisions

the toolkit needed two partitions for the supported OS's. We decided that keeping the directory structure identical between the two would be more consistent and intuitive for users. Four main folders were made to accomodate documentation, scripts, tools, and output locations. The output location itself contains files named after each tool, the documentation folder will contain all the usage guides and the tool index, whilst the scripts and tools will contain all necessary files for the tools and the runnable scripts. 

## Usability Observations

The toolkit makes the process of acquiring forensic evidence from physically accessible machines much smoother and easier, whilst providing thorough documentation on the usage and capabilities of the tools contained. This package ensures that the process of acquiring evidence whilst adhering to government or company policies is a more convenient and available process, whether used in fieldwork, for private use or for educational needs. There is the possibility that a bad actor could try and make use of the toolkit to steal sensitive data from a device, however the need for a physically accessible and elevated user account should help to prevent abuse of the toolkit's abilities. 

Economically, the tools contained are all open source or freely available, making it more accessible to smaller businesses or individual users who’d lack the resources to pay for higher expense tools. This would also ensure no legal concerns for whoever may use the toolkit, at least in regards to the packaged tools. Alongside being freely available, the documentation provided can help guide less experienced users in using the tools for smaller investigations without having to resort to contracting a professional. 

## Limitations and Future Recommendations

Most tools won't work without running them with elevated permissions (running as administrator on windows, using sudo on Linux), which would heavily limit the functionality of the toolkit on devices without an accessible elevated account. 

In a real world scenario, the outputs of all tools could use up all the storage on the allocated USB drive, causing issues when attempting a full acquisition of forensic evidence, especially if acquiring from a device with multiple drives. 