@echo off
title Python Embedded Environment Setup
setlocal enabledelayedexpansion

:: ==========================================
:: CONFIGURATION
:: ==========================================
set INSTALL_DIR=%CD%
set PY_VER=3.10.11
set PY_EMBED_DIR=%INSTALL_DIR%\python-embedded
set PY_EXE=%PY_EMBED_DIR%\python.exe
set PIP_EXE=%PY_EMBED_DIR%\Scripts\pip.exe
set PY_URL=https://www.python.org/ftp/python/%PY_VER%/python-%PY_VER%-embed-amd64.zip

echo.
echo ==========================================
echo   PYTHON EMBEDDED ENVIRONMENT SETUP
echo ==========================================
echo Installation directory: %INSTALL_DIR%
echo.

pause

:: ==========================================
:: INSTALL PYTHON EMBEDDED
:: ==========================================
if not exist "%PY_EXE%" (
    echo Python Embedded not found. Downloading version %PY_VER%...
    curl -L -o "%INSTALL_DIR%\python-embed.zip" "%PY_URL%"
    if errorlevel 1 (
        echo [ERROR] Failed to download Python Embedded.
        pause
        exit /b
    )
    mkdir "%PY_EMBED_DIR%" >nul 2>&1
    powershell -command "Expand-Archive -Path '%INSTALL_DIR%\python-embed.zip' -DestinationPath '%PY_EMBED_DIR%'"
    del "%INSTALL_DIR%\python-embed.zip"
    echo Python Embedded installed successfully.
) else (
    echo Python Embedded already present.
)
echo.

:: ==========================================
:: CONFIGURE PYTHON PATH FILE
:: ==========================================
if exist "%PY_EMBED_DIR%\python310._pth" (
    echo Configuring python310._pth file...
    copy /Y "%PY_EMBED_DIR%\python310._pth" "%PY_EMBED_DIR%\python310._pth.bak" >nul
    (
        echo python310.zip
        echo .
        echo .\Lib
        echo .\Scripts
        echo .\DLLs
        echo import site
    ) > "%PY_EMBED_DIR%\python310._pth"
    echo python310._pth configured successfully.
) else (
    echo [WARNING] python310._pth file not found.
)
echo.

:: ==========================================
:: INSTALL PIP
:: ==========================================
if not exist "%PIP_EXE%" (
    echo Installing pip...
    curl -sSL https://bootstrap.pypa.io/get-pip.py -o "%PY_EMBED_DIR%\get-pip.py"
    "%PY_EXE%" "%PY_EMBED_DIR%\get-pip.py"
    del "%PY_EMBED_DIR%\get-pip.py"
)
if not exist "%PIP_EXE%" (
    echo [ERROR] pip installation failed.
    pause
    exit /b
)
echo pip installed successfully.
echo.

:: ==========================================
:: INSTALL PROJECT DEPENDENCIES
:: ==========================================
if exist "%INSTALL_DIR%\requirements.txt" (
    echo Installing dependencies from requirements.txt...
    "%PIP_EXE%" install -r "%INSTALL_DIR%\requirements.txt"
    if errorlevel 1 (
        echo [ERROR] Failed to install dependencies.
        pause
        exit /b
    )
    echo Dependencies installed successfully.
) else (
    echo No requirements.txt found. Skipping dependency installation.
)
echo.

:: ==========================================
:: OPTIONAL: PYTORCH GPU SUPPORT
:: ==========================================
choice /m "Do you want to install PyTorch with CUDA GPU support?"
if errorlevel 2 (
    echo Skipping PyTorch installation.
) else (
    echo Installing PyTorch (CUDA 12.4)...
    "%PIP_EXE%" install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
)
echo.

:: ==========================================
:: ENVIRONMENT READY
:: ==========================================
echo Python environment successfully configured.
echo Python executable: %PY_EXE%
echo pip executable: %PIP_EXE%
echo.

:: ==========================================
:: LAUNCH PROJECT (if main.py exists)
:: ==========================================
if exist "%INSTALL_DIR%\main.py" (
    echo Launching main.py...
    "%PY_EXE%" "%INSTALL_DIR%\main.py" %*
) else (
    echo No main.py found. Environment is ready for manual use.
)
echo.
pause
exit /b
