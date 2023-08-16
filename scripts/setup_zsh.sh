#!/bin/sh

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install curl git unzip wget yadm zip zsh -y
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# code .zshrc
# change Theme "powerlevel10k/powerlevel10k" and plugin "git zsh-autosuggestions"
# cp ~/.zshrc ~/.zshrc.after-oh-my-zsh
# cp ~/.zshrc.pre-oh-my-zsh ~/.zshrc
