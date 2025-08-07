# Windows Terminal and Font Setup Script
# Run from WSL via PowerShell

param(
    [switch]$InstallFonts = $true,
    [switch]$ConfigureTerminal = $true
)

Write-Host "Starting Windows configuration..." -ForegroundColor Green

# Install Meslo Nerd Fonts
if ($InstallFonts) {
    Write-Host "Installing Meslo Nerd Fonts..." -ForegroundColor Yellow
    
    $fontPath = "/tmp/fonts"
    $windowsFontPath = "$env:WINDIR\Fonts"
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    
    # Convert WSL path to Windows path
    $wslFontPath = wsl wslpath -w $fontPath
    
    $fonts = @(
        @{Name = "MesloLGS NF Regular (TrueType)"; File = "MesloLGS NF Regular.ttf"},
        @{Name = "MesloLGS NF Bold (TrueType)"; File = "MesloLGS NF Bold.ttf"},
        @{Name = "MesloLGS NF Italic (TrueType)"; File = "MesloLGS NF Italic.ttf"},
        @{Name = "MesloLGS NF Bold Italic (TrueType)"; File = "MesloLGS NF Bold Italic.ttf"}
    )
    
    foreach ($font in $fonts) {
        $sourcePath = Join-Path $wslFontPath $font.File
        $destPath = Join-Path $windowsFontPath $font.File
        
        if (Test-Path $sourcePath) {
            try {
                # Copy font file
                Copy-Item $sourcePath $destPath -Force
                
                # Register font in registry
                Set-ItemProperty -Path $registryPath -Name $font.Name -Value $font.File -Force
                
                Write-Host "  Installed: $($font.File)" -ForegroundColor Green
            }
            catch {
                Write-Host "  Failed to install: $($font.File) - $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        else {
            Write-Host "  Font file not found: $sourcePath" -ForegroundColor Red
        }
    }
    
    # Refresh font cache
    try {
        Add-Type -AssemblyName PresentationCore
        [System.Windows.Media.Fonts]::SystemFontFamilies | Out-Null
        Write-Host "Font cache refreshed" -ForegroundColor Green
    }
    catch {
        Write-Host "Could not refresh font cache automatically" -ForegroundColor Yellow
    }
}

# Configure Windows Terminal
if ($ConfigureTerminal) {
    Write-Host "Configuring Windows Terminal..." -ForegroundColor Yellow
    
    # Find Windows Terminal settings path
    $wtSettingsPath = Get-ChildItem "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_*\LocalState\settings.json" -ErrorAction SilentlyContinue | Select-Object -First 1
    
    if ($wtSettingsPath) {
        $settingsFile = $wtSettingsPath.FullName
        Write-Host "Found Windows Terminal settings: $settingsFile" -ForegroundColor Green
        
        try {
            # Backup current settings
            $backupPath = "$settingsFile.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Copy-Item $settingsFile $backupPath
            Write-Host "Settings backed up to: $backupPath" -ForegroundColor Green
            
            # Read current settings
            $settings = Get-Content $settingsFile -Raw | ConvertFrom-Json
            
            # Configure defaults
            if (-not $settings.profiles) { $settings.profiles = @{} }
            if (-not $settings.profiles.defaults) { $settings.profiles.defaults = @{} }
            
            $settings.profiles.defaults.fontFace = "MesloLGS NF"
            $settings.profiles.defaults.fontSize = 10
            $settings.profiles.defaults.colorScheme = "Campbell Powershell"
            
            # Find WSL profile and set as default
            $wslProfile = $settings.profiles.list | Where-Object { $_.name -like "*Ubuntu*" -or $_.source -eq "Windows.Terminal.Wsl" } | Select-Object -First 1
            if ($wslProfile) {
                $settings.defaultProfile = $wslProfile.guid
                Write-Host "Set WSL profile as default: $($wslProfile.name)" -ForegroundColor Green
            }
            
            # Enable acrylic and set theme
            $settings.profiles.defaults.useAcrylic = $true
            $settings.profiles.defaults.acrylicOpacity = 0.8
            
            # Save updated settings
            $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsFile -Encoding UTF8
            Write-Host "Windows Terminal configured successfully" -ForegroundColor Green
            
        }
        catch {
            Write-Host "Error configuring Windows Terminal: $($_.Exception.Message)" -ForegroundColor Red
            # Restore backup if something went wrong
            if (Test-Path $backupPath) {
                Copy-Item $backupPath $settingsFile -Force
                Write-Host "Settings restored from backup" -ForegroundColor Yellow
            }
        }
    }
    else {
        Write-Host "Windows Terminal not found. Please install it from Microsoft Store." -ForegroundColor Red
    }
}

Write-Host "Windows configuration completed!" -ForegroundColor Green
Write-Host "Please restart Windows Terminal to see the changes." -ForegroundColor Yellow