@echo off
cd ..\..\output\

for /R %%F in (*) do (
    if /i not "%%~xF"==".sha256" (
        certutil -hashfile "%%F" SHA256 | findstr /v "certutil:" | findstr /v "sha256 hash of" > "%%F.sha256"
		set "append_text= %%F"
		(for /f "usebackq delims=" %%A in ("%%F.sha256") do (
				echo %%A %%~nxF
		)) > temp.txt
		move /y temp.txt %%F.sha256 > nul
    )
)