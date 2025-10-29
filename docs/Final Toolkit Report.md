
# Final Report KIT325 Assignment Task 3


## Brief Introduction

The goal of this project was to create a lightweight, portable forensics toolkit situated on a USB storage device. When defining the scope, we decided to base the toolkit around being acquisition focused, designed to capture evidence in the field and bring it to a larger workstation for further dissemination. For this scope, we outlined the core functionality we needed from tools, being memory capture, disk imaging, registry analysis, file carving, and file acquisition. We also decided on having the toolkit be hybrid focused, with hot and cold tools for both linux and windows systems, requiring us to also create a Linux distro environment for the coldboot side of the drive. This report highlights the finer details of the project, explaining tool selection, testing results in regards to the SPDA document, usability observations, limitations, and future recommendations for the created toolkit.

## Rationale for Tool Selection

- explain rationale behind selecting tools


### WinPmem and AVML

WinPmem and AVML were selected as our memory capturing tools for Windows and Linux systems. AVML was chosen as it stood out as a commercially available and simple to use tool that would suit the needs of the toolkit perfectly, being capturing memory from Linux systems, and outputting it in a suitable file format. Whilst many other options could also have been suitable, AVML was the first selected and passed all tests set for it, so there was no need to trial others. WinPmem on the other hand, was almost the exact opposite. We went to great lengths to find a windows memory capturing tool that was specifically available for commercial use. A great many tools were considered, but could not be used primarily because of licensing concerns, such as FTK Imager, MAGNET RAM, FEX Memory Imager and more. This left us with WinPmem as essentially the only resulting tool we could find so far, however it looked to be suitable for the needs of the toolkit, even if it outputs the resulting memory file in the .raw format.

### Photorec

Photorec was chosen as our designated file carving option for a few key reasons. Firstly, whilst looking around for available options, Photorec appeared to be the standard choice, and commonly appeared amongst the options. It is also an open source tool, letting us use it without licensing concern in this project, and is already an ingest module integrated into autopsy, another tool we plan on using. When looked further into, the tool seemed sufficiently capable for our needs, and worked on both windows and linux operating systems. As such, we chose it to be tested first as our file carving tool. 

## Testing Results


### Memory Capture Tools

Our testing criteria for the memory capturing tools involved two main tests to pass. The first was successful usage of the tool without any issues. In this regard, both WinPmem and AVML managed to produce .raw and .mem files of their systems memory with little difficulty. A virtual machine for Linux was used to test AVML as I lacked access to a Linux device, however AVML still performed as expected in this environment. 

The second main test involved successfully operating the tools from and storing the outputted memory files on a mounted USB drive. As I lack access to larger USB drives at the moment of testing, a 4gb USB was used, and the tools were only checked to have started creating a memory file instead of creating a full size file. For this test, WinPmem worked without issue, successfully running on and creating an output file on a USB drive, up until the drive ran out of space. AVML however had initial complications, specifically around execute permissions being different between the linux system and the window’s like formatting of the drive. With some troubleshooting and work arounds, we found a way to get the tool working again. By changing the avml file to avml.exe, the drive recognizes it as an executable and gives it permission to be run as such. Adding the dynamic linker (/lib64/ld-linux-x86-64.so.2) to the command was also necessary to ensure the executable functioned correctly. With these changes, AVML was also able to create a .mem file of captured image up until again, the drive ran out of storage. 

A final test was included based on a suggestion from the second progress meeting. This test includes checking that the outputted .mem and .raw files are actually readable by memory analysis tools, and are useful for further examination. For this test, volatility 3 was used to examine the files from both avml and winpmem. When running a simple windows.info check on both the .mem and .raw files, the tool correctly read and displayed information on the contents of these memory files, showing that they were suitable for use.

### Photorec

From the SPDA document, the main testing criteria for Photorec is for the tool to be able to reconstruct files from unallocated space that match the contents of their original version. Whilst doing this, I also opted to ensure the tool works without issue on both windows and linux systems and when operating from a USB drive instead of the system itself. For the first test, a sample text file was created with an identifiable size and with easily recognizable contents. Once deleted, Photorec was able to recover the file and match it’s original content on both systems without issue, matching the files length and contents.
![Photorec Test Passed](https://github.com/jbat10/KIT325/blob/main/docs/Images/PhotorecReportWin.PNG)
![Photorec Test Passed](https://github.com/jbat10/KIT325/blob/main/docs/Images/PhotorecReportLin.PNG)
*Above are the successfully recovered files from Photorec*

For the second test, these results largely mirror the memory capture tools with their outcomes. The windows version functioned without issue from the USB drive, however the linux version needed extra modification to work without issue. 

## Packaging Decisions

the toolkit needed two partitions for the supported OS's. We decided that keeping the directory structure identical between the two would be more consistent and intuitive for users. Three main folders were made to accomodate documentatoin, scripts and tools, and output locations. The output location itself contains files named after each tool, the documentation folder will contain all the usage guides and the tool index, whilst the scripts and tools will contain all necessary files for the tools and the runnable scripts. 

## Usability Observations

The toolkit makes the process of acquiring forensic evidence from physically accessible machines much smoother and easier, whilst providing thorough documentation on the usage and capabilities of the tools contained. This package ensures that the process of acquiring evidence whilst adhering to government or company policies is a more convenient and available process, whether used in fieldwork, for private use or for educational needs. There is the possibility that a bad actor could try and make use of the toolkit to steal sensitive data from a device, however the need for a physically accessible and elevated user account should help to prevent abuse of the toolkit's abilities. 

Economically, the tools contained are all open source or freely available, making it more accessible to smaller businesses or individual users who’d lack the resources to pay for higher expense tools. This would also ensure no legal concerns for whoever may use the toolkit, at least in regards to the packaged tools. Alongside being freely available, the documentation provided can help guide less experienced users in using the tools for smaller investigations without having to resort to contracting a professional. 

## Limitations and Future Recommendations

most tools won't work without running them with elevated permissions (running as administrator on windows, using sudo on Linux), which would heavily limit the functionality of the toolkit on devices without an accessible elevated account. 

In a real world scenario, the outputs of all tools could use up all the storage on the allocated USB drive, causing issues when attempting a full acquisition of forensic evidence, especially if acquiring from a device with multiple drives. A future recommendation would be to use a USB drive with a larger storage to alleviate this issue, however having multiple sets of this toolkit to bring with could also work when multiple drives are involved.