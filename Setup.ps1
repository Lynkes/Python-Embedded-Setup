<#
Python Embedded Environment Setup
---------------------------------
Professional Setup Script for a self-contained Python environment.

Author: Pedro (with ChatGPT)
#>

# ========================
# CONFIGURATION
# ========================
$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "Python Embedded Environment Setup"

$InstallDir = (Get-Location).Path
$PythonVer  = "3.10.11"
$PythonDir  = "$InstallDir\python-embedded"
$PythonExe  = "$PythonDir\python.exe"
$PipExe     = "$PythonDir\Scripts\pip.exe"
$PythonUrl  = "https://www.python.org/ftp/python/$PythonVer/python-$PythonVer-embed-amd64.zip"
$SplashText = "Preparing Python Environment..."

[Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$PythonDir\Scripts", "Process")

# ========================
# VISUAL FUNCTIONS
# ========================
function Write-Logo {
    Clear-Host
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║             PYTHON EMBEDDED SETUP TOOL             ║" -ForegroundColor White
    Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Info($msg) { Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "[ OK ]  $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "[FAIL]  $msg" -ForegroundColor Red }

# Progress simulation (for smooth UI)
function Simulate-Progress([string]$Activity, [int]$DurationSec = 2) {
    for ($i = 0; $i -le 100; $i += 5) {
        Write-Progress -Activity $Activity -Status "$i% Complete" -PercentComplete $i
        Start-Sleep -Milliseconds ($DurationSec * 50)
    }
    Write-Progress -Activity $Activity -Completed
}

function Wait-Exit {
    Write-Host ""
    Write-Host "Press ENTER to exit..." -ForegroundColor DarkGray
    try { $null = Read-Host } catch { Start-Sleep -Seconds 10 }
}

# ========================
# SPLASH SCREEN
# ========================
Write-Logo
Write-Host "🔧  $SplashText" -ForegroundColor Cyan
Simulate-Progress -Activity "Initializing setup..." -DurationSec 2
Start-Sleep -Milliseconds 400
Clear-Host
Write-Logo
Write-Host "Installation directory: $InstallDir" -ForegroundColor Gray
Write-Host ""
Pause

# ========================
# MAIN LOGIC
# ========================
try {
    # --- Download Python ---
    if (!(Test-Path $PythonExe)) {
        Write-Info "Downloading Python $PythonVer..."
        $zipPath = "$InstallDir\python-embed.zip"
        $web = New-Object System.Net.WebClient
        $web.DownloadFile($PythonUrl, $zipPath)
        Write-Info "Extracting archive..."
        Expand-Archive -Path $zipPath -DestinationPath $PythonDir -Force
        Remove-Item $zipPath -Force
        Write-OK "Python Embedded installed successfully."
    } else {
        Write-OK "Python already installed."
    }

    # --- Configure ._pth ---
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
        Write-OK "Path configuration complete."
    }

    # --- Install pip ---
    if (!(Test-Path $PipExe)) {
        Write-Info "Installing pip..."
        $getPip = "$PythonDir\get-pip.py"
        Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile $getPip
        & $PythonExe $getPip 2>&1 | Out-String | Write-Host
        Remove-Item $getPip -Force
        if (!(Test-Path $PipExe)) { throw "pip installation failed." }
        Write-OK "pip installed successfully."
    } else {
        Write-OK "pip already present."
    }

    # --- Dependencies ---
    $reqFile = "$InstallDir\requirements.txt"
    if (Test-Path $reqFile) {
        Write-Info "Installing dependencies..."
        & $PipExe install -r $reqFile
        Write-OK "Dependencies installed."
    } else {
        Write-Warn "No requirements.txt found."
    }

    # --- Optional PyTorch ---
    $choice = Read-Host "Install PyTorch with CUDA support? (Y/N)"
    if ($choice -match "^[Yy]") {
        Write-Info "Installing PyTorch (CUDA 12.4)..."
        & $PipExe install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
        Write-OK "PyTorch installed."
    } else {
        Write-Warn "PyTorch installation skipped."
    }

    # --- Final summary ---
    Write-Host ""
    Write-OK "Python environment successfully configured!"
    Write-Host "Python executable: $PythonExe" -ForegroundColor Gray
    Write-Host "pip executable: $PipExe" -ForegroundColor Gray
    Write-Host ""

    # --- Launch app if exists ---
    $main = "$InstallDir\main.py"
    if (Test-Path $main) {
        Write-Info "Launching main.py..."
        & $PythonExe $main
    } else {
        Write-Warn "No main.py found."
    }

} catch {
    Write-Host ""
    Write-Err "An error occurred: $($_.Exception.Message)"
    if ($_.InvocationInfo.PositionMessage) {
        Write-Host "At: $($_.InvocationInfo.PositionMessage)" -ForegroundColor DarkRed
    }
} finally {
    Wait-Exit
}
