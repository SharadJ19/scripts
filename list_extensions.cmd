@echo off
setlocal EnableDelayedExpansion

REM ===== SET ROOT FOLDER =====
set ROOT_DIR=C:\Users\sharad\Downloads\Anju Maam Assignment\Images\Images

REM ===== FILES =====
set TEMP_FILE=%temp%\extensions.txt
set OUTPUT_FILE=%ROOT_DIR%\extensions_used.txt

REM Create empty temp file
type nul > "%TEMP_FILE%"

REM Scan all files recursively (page 1, page 2, etc.)
for /r "%ROOT_DIR%" %%F in (*) do (
    if not "%%~xF"=="" echo %%~xF>>"%TEMP_FILE%"
)

REM Check if temp file has data
for %%A in ("%TEMP_FILE%") do if %%~zA==0 (
    echo No files with extensions found.
    goto :end
)

REM Sort + unique
sort "%TEMP_FILE%" /unique > "%OUTPUT_FILE%"

echo Done. Extensions saved to:
echo %OUTPUT_FILE%

:end
del "%TEMP_FILE%"
endlocal
pause
