#!/bin/bash

cd tools/windows/

wget https://download.ericzimmermanstools.com/net9/RECmd.zip
unzip RECmd.zip
rm RECmd.zip

wget https://github.com/thewhiteninja/ntfstool/releases/download/v1.7/ntfstool.x86.exe

wget https://github.com/thewhiteninja/ntfstool/releases/download/v1.7/ntfstool.x64.exe

wget https://github.com/Velocidex/WinPmem/releases/download/v4.0.rc1/winpmem_mini_x86.exe
mv winpmem_mini_x86.exe winpmem.exe

wget https://www.cgsecurity.org/testdisk-7.2.win64.zip
unzip testdisk-7.2.win64.zip
rm testdisk-7.2.win64.zip
mv testdisk-7.2/ testdisk_win/

mkdir dotnet
cd dotnet/
wget https://builds.dotnet.microsoft.com/dotnet/Runtime/9.0.10/dotnet-runtime-9.0.10-win-x86.zip
unzip dotnet-runtime-9.0.10-win-x86.zip
rm dotnet-runtime-9.0.10-win-x86.zip


cd ../../Linux/

wget -O avml.exe https://github.com/microsoft/avml/releases/download/v0.14.0/avml

wget https://www.cgsecurity.org/testdisk-7.2.linux26-x86_64.tar.bz2
tar -xf testdisk-7.2.linux26-x86_64.tar.bz2
rm testdisk-7.2.linux26-x86_64.tar.bz2
mv testdisk-7.2/ testdisk/
