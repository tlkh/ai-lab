#!/bin/bash

echo "[INFO] Check for ZSH"
zsh --version
echo "[INFO] Change default shell to ZSH"
chsh -s $(which zsh)
echo "[INFO] Install oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
echo "[INFO] Copy config file to /home/$USER/.zshrc"
cp ./zshrc /home/$USER/.zshrc
echo "[INFO] Install plugins"
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
echo "[INFO] Extra: configure git to store credentials"
git config --global  credential.helper store
