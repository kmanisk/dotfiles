@ECHO OFF
SETLOCAL

REM Extract the file path and extension
SET "file_path=%ZED_DIRNAME%\%ZED_STEM%"

FOR %%F in ("%ZED_FILE%") DO (
    SET "extension=%%~xF"
)

REM Change directory for proper file operations
CD %ZED_DIRNAME%

ECHO [Running %ZED_FILENAME%]

REM Check if the file is a .py file
IF /I "%extension%" == ".py" (
    REM Run the Python script
    python "%ZED_FILE%" < CON
) ELSE (
    ECHO ERROR: Unsupported file type.
)

ENDLOCAL
@ECHO OFF
SETLOCAL

REM Extract the file path and extension
SET "file_path=%ZED_DIRNAME%\%ZED_STEM%"

FOR %%F in ("%ZED_FILE%") DO (
    SET "extension=%%~xF"
)

REM Change directory for proper file operations
CD %ZED_DIRNAME%

ECHO [Running %ZED_FILENAME%]

REM Check if the file is a .py file
IF /I "%extension%" == ".py" (
    REM Run the Python script
    python "%ZED_FILE%" < CON
) ELSE (
    ECHO ERROR: Unsupported file type.
)

ENDLOCAL
