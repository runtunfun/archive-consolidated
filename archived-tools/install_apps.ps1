# Install applications using winget

# Führen Sie PowerShell als Administrator aus und navigieren zum Speicherort der Datei.
# Führen Sie den Befehl Set-ExecutionPolicy RemoteSigned aus, um die Ausführung von Skripten zu erlauben (falls noch nicht geschehen).
# Schließlich führen Sie das Skript mit .\install_apps.ps1 aus.

$apps = @(
    "Microsoft.WindowsTerminal",
    "Git.Git",
    "7zip.7zip",
    "Oracle.VirtualBox",
    "HashiCorp.Vagrant",
    "Docker.DockerDesktop",
    "Google.Chrome",
    "Mozilla.Firefox",
    "AgileBits.1Password",
    "Microsoft.VisualStudioCode",
    "JGraph.Draw",
    "OpenVPNTechnologies.OpenVPN"
)

foreach ($app in $apps) {
    Write-Host "Installing $app"
    winget install -e --id $app
}

Write-Host "Installation complete."
