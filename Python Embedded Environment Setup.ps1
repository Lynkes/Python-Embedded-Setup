<#
Python Embedded Environment Setup
---------------------------------
This script automatically downloads and configures a portable Python environment
for your project. It installs pip, dependencies, and optionally PyTorch with CUDA.

Author: Pedro (adapted by ChatGPT)
#>

# ========================
# Configuration
# ========================
$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "Python Embedded Environment Setup"

$InstallDir = (Get-Location).Path
$PythonVer = "3.10.11"
$PythonDir = "$InstallDir\python-embedded"
$PythonExe = "$PythonDir\python.exe"
$PipExe = "$PythonDir\Scripts\pip.exe"
$PythonUrl = "https://www.python.org/ftp/python/$PythonVer/python-$PythonVer-embed-amd64.zip"

# ========================
# Helper functions
# ========================
function Write-Info($msg) { Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "[ OK ]  $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "[FAIL]  $msg" -ForegroundColor Red }

# ========================
# Banner
# ========================
Clear-Host
Write-Host ""
Write-Host "==========================================" -ForegroundColor White
Write-Host "  PYTHON EMBEDDED ENVIRONMENT SETUP" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor White
Write-Host "Installation directory: $InstallDir" -ForegroundColor Gray
Write-Host ""
Pause

# ========================
# Install Python Embedded
# ========================
if (!(Test-Path $PythonExe)) {
    Write-Info "Python Embedded not found. Downloading version $PythonVer..."
    $zipPath = "$InstallDir\python-embed.zip"
    Invoke-WebRequest -Uri $PythonUrl -OutFile $zipPath

    Write-Info "Extracting archive..."
    Expand-Archive -Path $zipPath -DestinationPath $PythonDir -Force
    Remove-Item $zipPath -Force
    Write-OK "Python Embedded installed successfully."
} else {
    Write-OK "Python Embedded already present."
}

# ========================
# Configure python310._pth
# ========================
$pthFile = "$PythonDir\python310._pth"
if (Test-Path $pthFile) {
    Write-Info "Configuring python310._pth..."
    Copy-Item $pthFile "$pthFile.bak" -Force
    @"
python310.zip
.
.\Lib
.\Scripts
.\DLLs
import site
"@ | Out-File -Encoding ascii -FilePath $pthFile
    Write-OK "python310._pth configured."
} else {
    Write-Warn "python310._pth file not found."
}

# ========================
# Install pip
# ========================
if (!(Test-Path $PipExe)) {
    Write-Info "Installing pip..."
    $getPip = "$PythonDir\get-pip.py"
    Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile $getPip
    & $PythonExe $getPip
    Remove-Item $getPip -Force
}
if (!(Test-Path $PipExe)) {
    Write-Err "pip installation failed."
    Pause
    exit 1
}
Write-OK "pip installed successfully."

# ========================
# Install dependencies
# ========================
$reqFile = "$InstallDir\requirements.txt"
if (Test-Path $reqFile) {
    Write-Info "Installing dependencies from requirements.txt..."
    & $PipExe install -r $reqFile
    Write-OK "Dependencies installed successfully."
} else {
    Write-Warn "No requirements.txt found. Skipping dependency installation."
}

# ========================
# Optional: PyTorch with CUDA
# ========================
$choice = Read-Host "Do you want to install PyTorch with CUDA support? (Y/N)"
if ($choice -match "^[Yy]") {
    Write-Info "Installing PyTorch (CUDA 12.4)..."
    & $PipExe install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
    Write-OK "PyTorch installed successfully."
} else {
    Write-Warn "Skipping PyTorch installation."
}

# ========================
# Final summary
# ========================
Write-Host ""
Write-OK "Python environment successfully configured!"
Write-Host "Python executable: $PythonExe" -ForegroundColor Gray
Write-Host "pip executable: $PipExe" -ForegroundColor Gray
Write-Host ""

# ========================
# Launch project (optional)
# ========================
$main = "$InstallDir\main.py"
if (Test-Path $main) {
    Write-Info "Launching main.py..."
    & $PythonExe $main
} else {
    Write-Warn "No main.py found. Environment ready for manual use."
}

Pause
