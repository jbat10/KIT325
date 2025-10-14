
# Final Report KIT325 Assignment Task 3


## Brief Introduction

- explain the project here, no need to go into depth

## Tool Selection

- explain rationale behind selecting tools


### Rationale for the selected memory capture tools

WinPmem and AVML were selected as our memory capturing tools for Windows and Linux systems. Avml was chosen as it stood out as a commercially available and simple to use tool that would suit the needs of the toolkit perfectly, being capturing memory from Linux systems, and outputting it in a suitable file format. Whilst many other options could also have been suitable, AVML was the first selected and passed all tests set for it, so there was no need to trial others. WinPmem on the other hand, was almost the exact opposite. We went to great lengths to find a windows memory capturing tool that was specifically available for commercial use. A great many tools were considered, but could not be used primarily because of licensing concerns, such as FTK Imager, MAGNET RAM, FEX Memory Imager and more. This left us with WinPmem as essentially the only resulting tool we could find so far, however it looked to be suitable for the needs of the toolkit, even if it outputs the resulting memory file in the .raw format.


## Testing Results


### Memory Capture Tools

Our testing criteria for the memory capturing tools involved two main tests to pass. The first was successful usage of the tool without any issues. In this regard, both WinPmem and AVML managed to produce .raw and .mem files of their systems memory with little difficulty. A virtual machine for Linux was used to test AVML as I lacked access to a Linux device, however AVML still performed as expected in this environment. 

The second main test involved successfully operating the tools from and storing the outputted memory files on a mounted USB drive. As I lack access to larger USB drives at the moment of testing, a 4gb USB was used, and the tools were only checked to have started creating a memory file instead of creating a full size file. For this test, WinPmem worked without issue, successfully running on and creating an output file on a USB drive, up until the drive ran out of space. AVML however had initial complications.

## Packaging Decisions


## Usability Observations


## Limitations and Future Recommendations


