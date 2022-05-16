#!/bin/sh

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install curl git yadm zsh
# git config --global user.name "Stefan Kuehn"; git config --global user.email "stefan.kuehn@etomer.com"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
code .zshrc
# change Theme "powerlevel10k/powerlevel10k" und plugin "git zsh-autosuggestions"
yadm clone git@support2.etomer.com:sk0001/dotfiles.git
