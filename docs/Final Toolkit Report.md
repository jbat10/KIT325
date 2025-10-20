
# Final Report KIT325 Assignment Task 3


## Brief Introduction

- explain the project here, no need to go into depth

## Rationale for Tool Selection

- explain rationale behind selecting tools


### WinPmem and AVML

WinPmem and AVML were selected as our memory capturing tools for Windows and Linux systems. Avml was chosen as it stood out as a commercially available and simple to use tool that would suit the needs of the toolkit perfectly, being capturing memory from Linux systems, and outputting it in a suitable file format. Whilst many other options could also have been suitable, AVML was the first selected and passed all tests set for it, so there was no need to trial others. WinPmem on the other hand, was almost the exact opposite. We went to great lengths to find a windows memory capturing tool that was specifically available for commercial use. A great many tools were considered, but could not be used primarily because of licensing concerns, such as FTK Imager, MAGNET RAM, FEX Memory Imager and more. This left us with WinPmem as essentially the only resulting tool we could find so far, however it looked to be suitable for the needs of the toolkit, even if it outputs the resulting memory file in the .raw format.

### Photorec

Photorec was chosen as our designated file carving option for a few key reasons. Firstly, whilst looking around for available options, Photorec appeared to be the standard choice, and commonly appeared amongst the options. It is also an open source tool, letting us use it without licensing concern in this project, and is already an ingest module integrated into autopsy, another tool we plan on using. When looked further into, the tool seemed sufficiently capable for our needs, and worked on both windows and linux operating systems. As such, we chose it to be tested first as our file carving tool. 

## Testing Results


### Memory Capture Tools

Our testing criteria for the memory capturing tools involved two main tests to pass. The first was successful usage of the tool without any issues. In this regard, both WinPmem and AVML managed to produce .raw and .mem files of their systems memory with little difficulty. A virtual machine for Linux was used to test AVML as I lacked access to a Linux device, however AVML still performed as expected in this environment. 

The second main test involved successfully operating the tools from and storing the outputted memory files on a mounted USB drive. As I lack access to larger USB drives at the moment of testing, a 4gb USB was used, and the tools were only checked to have started creating a memory file instead of creating a full size file. For this test, WinPmem worked without issue, successfully running on and creating an output file on a USB drive, up until the drive ran out of space. AVML however had initial complications, specifically around execute permissions being different between the linux system and the window’s like formatting of the drive. With some troubleshooting and work arounds, we found a way to get the tool working again. By changing the avml file to avml.exe, the drive recognizes it as an executable and gives it permission to be run as such. Adding the dynamic linker (/lib64/ld-linux-x86-64.so.2) to the command was also necessary to ensure the executable functioned correctly. With these changes, AVML was also able to create a .mem file of captured image up until again, the drive ran out of storage. 

!!!SHOULD FURTHER TEST THESE ONCE A LARGER DRIVE IS ACQUIRED!!!

### Photorec

From the SPDA document, the main testing criteria for Photorec is for the tool to be able to reconstruct files from unallocated space that match the contents of their original version. Whilst doing this, I also opted to ensure the tool works without issue on both windows and linux systems and when operating from a USB drive instead of the system itself. For the first test, a sample text file was created with an identifiable size and with easily recognizable contents. Once deleted, Photorec was able to recover the file and match it’s original content on both systems without issue, matching the files length and contents.
![Photorec Test Passed](https://github.com/jbat10/KIT325/blob/main/docs/Images/PhotorecReportWin.PNG)
![Photorec Test Passed](https://github.com/jbat10/KIT325/blob/main/docs/Images/PhotorecReportLin.PNG)


For the second test, these results largely mirror the memory capture tools with their outcomes. The windows version functioned without issue from the USB drive, however the linux version needed extra modification to work without issue. 

## Packaging Decisions


## Usability Observations


## Limitations and Future Recommendations

things that could be mentioned
- running tools from usb could have issues
- the output of the winpmem run is in .raw format, and would need further work after acquisition to alter the file to a readable format such as .mem. Having this in built in the toolkit could be useful. 
