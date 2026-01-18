@echo off
setlocal

REM ===== ROOT FOLDER =====
set ROOT_DIR=C:\Users\sharad\Downloads\Anju Maam Assignment\Images\Images

REM ===== TOOLS =====
set MAGICK=D:\Software\ImageMagick\magick.exe

REM ===== GHOSTSCRIPT (PORTABLE) =====
set "PATH=D:\Software\Ghostscript\bin;%PATH%"

echo Converting images to PNG...
echo.

for /r "%ROOT_DIR%" %%F in (
    *.bmp *.gif *.jpg *.jpeg *.pct *.pcx *.eps *.pdf *.psd *.tga *.tif *.tiff *.wmf *.ai
) do (
    if not exist "%%~dpnF.png" (
        echo Converting: %%~fF
        pushd "%%~dpF"
        "%MAGICK%" -- "%%~nxF" "%%~nF.png"
        popd
    )
)

echo.
echo Done.
pause
endlocal