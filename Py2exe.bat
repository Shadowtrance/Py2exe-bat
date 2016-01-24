@echo off
REM Name this bat file the same name as the python script to convert.
REM For example... MyScript.py = MyScript.bat

REM Set personal Path to the Apps:
set PythonEXE="C:\Python27\python.exe"
set SevenZipEXE="C:\Program Files\7-Zip\7z.exe"
set UpxEXE="C:\Python27\upx.exe"


REM Compress=1 - Use CompressFiles
REM Compress=0 - Don't CompressFiles
set Compress=1


if not exist %~dpn0.py          call :FileNotFound %~dpn0.py
if not exist %PythonEXE%        call :FileNotFound %PythonEXE%
if not exist %SevenZipEXE%      call :FileNotFound %SevenZipEXE%
if not exist %UpxEXE%           call :FileNotFound %UpxEXE%


REMWrite the Py2EXE-Setup File
call :MakeSetupFile >"%~dpn0_EXESetup.py"


REMCompile the Python-Script
%PythonEXE% "%~dpn0_EXESetup.py" py2exe
if not "%errorlevel%"=="0" (
        echo Py2EXE Error!
        pause
        goto:eof
)


REM Delete the Py2EXE-Setup File
del "%~dpn0_EXESetup.py"


REM Copy the Py2EXE Results to the SubDirectory and Clean Py2EXE-Results
rd build /s /q
xcopy dist\*.* "%~dpn0_EXE\" /d /y
REM I use xcopy dist\*.* "%~dpn0_EXE\" /s /d /y
REM This is necessary when you have subdirectories - like when you use Tkinter
rd dist /s /q


if "%Compress%"=="1" call:CompressFiles
echo.
echo.
echo Done: "%~dpn0_EXE\"
echo.
pause
goto:eof


:CompressFiles
REM The 7zip part doesn't seem to play nice with bundle_files = 1. See MakeSetupFile below.
REM So either 1. Don't use bundle_files or 2. Don't use the repack library.zip 7zip option.

REM Uncomment these lines if you want to use the 7zip option in addition to upx.

REM        %SevenZipEXE% -aoa x "%~dpn0_EXE\library.zip" -o"%~dpn0_EXE\library\"
REM        del "%~dpn0_EXE\library.zip"

REM        cd "%~dpn0_EXE\library\"
REM        %SevenZipEXE% a -tzip -mx9 "%~dpn0_EXE\library.zip" -r
REM        cd..
REM        rd "%~dpn0_EXE\library" /s /q

REM ==============================================================================================

        cd "%~dpn0_EXE\"
REM        %UpxEXE% --best *.* REM Comment the next line out and uncomment this line if using the 7zip option.
                               REM I find this way better if you're looking to have a SINGLE exe file output
                               REM rather than a smaller exe and multiple files in a folder.
        %UpxEXE% --best *.exe
goto:eof


REM Change this to suit your needs. See http://www.py2exe.org/index.cgi/ListOfOptions
:MakeSetupFile
        echo.
        echo from distutils.core import setup
        echo import py2exe
        echo.
        echo py2exe_options = dict(
        echo                       compressed = 1,
        echo                       optimize = 2,
        echo                       bundle_files = 1,
        echo                       excludes = ['_ssl',
        echo                                   'pyreadline', 'difflib', 'doctest', 'locale', 
        echo                                   'optparse', 'pickle', 'calendar'],
        echo                       dll_excludes = ['msvcr71.dll', 'w9xpopen.exe'],
        echo                       )
        echo.
        echo setup(
        echo     options = {'py2exe': py2exe_options},
        echo     zipfile = None,
        echo     console = [
        echo         {
        echo             "script": r"%~dpn0.py",
        echo             "icon_resources": [(0, "icon.ico")]
        echo         }
        echo     ],
        echo )
        echo.
goto:eof


:FileNotFound
        echo.
        echo Error, File not found:
        echo [%1]
        echo.
        echo Check Path in %~nx0???
        echo.
        pause
        exit
goto:eof
