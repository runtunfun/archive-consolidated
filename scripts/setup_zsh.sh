#!/bin/sh

# Function to update package database and install packages
update_and_install() {
    # Update package database
    if [ "$1" = "redhat" ]; then
        sudo yum update -y
    elif [ "$1" = "suse" ]; then
        sudo zypper refresh
    elif [ "$1" = "debian" ]; then
        sudo apt-get update
        sudo apt-get upgrade -y
    else
        echo "Unknown distribution: $1"
        exit 1
    fi
    
    # Install packages if not already installed
    for pkg in curl git unzip sudo wget yadm zip zsh; do
        if ! command -v $pkg >/dev/null 2>&1; then
            echo "Installing $pkg..."
            if [ "$1" = "redhat" ]; then
                sudo yum install -y $pkg
            elif [ "$1" = "suse" ]; then
                sudo zypper install -y $pkg
            elif [ "$1" = "debian" ]; then
                sudo apt-get install -y $pkg
            fi
        else
            echo "$pkg is already installed."
        fi
    done
}

# Detect distribution
if [ -f /etc/redhat-release ]; then
    distribution="redhat"
elif [ -f /etc/SuSE-release ]; then
    distribution="suse"
elif [ -f /etc/debian_version ]; then
    distribution="debian"
else
    echo "Unknown distribution."
    exit 1
fi

echo "Detected distribution: $distribution"

# Call the function
update_and_install "$distribution"

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# code .zshrc
# change Theme "powerlevel10k/powerlevel10k" and plugin "git zsh-autosuggestions"
# cp ~/.zshrc ~/.zshrc.after-oh-my-zsh
# cp ~/.zshrc.pre-oh-my-zsh ~/.zshrc

# WSL-specific Windows configuration
if grep -qi microsoft /proc/version; then
    echo "WSL detected - configuring Windows Terminal and fonts..."
    
    # Download Meslo Nerd Font
    mkdir -p /tmp/fonts
    cd /tmp/fonts
    curl -fLo "MesloLGS NF Regular.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    curl -fLo "MesloLGS NF Bold.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
    curl -fLo "MesloLGS NF Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
    curl -fLo "MesloLGS NF Bold Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
    
    # Call PowerShell script for Windows-specific configuration
    powershell.exe -ExecutionPolicy Bypass -File "$(wslpath -w "$(dirname "$0")/setup_windows.ps1")"
    
    # Clean up
    rm -rf /tmp/fonts
    
    echo "Windows Terminal configuration completed. Please restart Windows Terminal."
fi
