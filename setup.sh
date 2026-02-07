#!/bin/bash

# exit on error
set -e

echo "starting setup"

# update and install base deps
echo "installing base dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget zip unzip zsh software-properties-common build-essential

if [ -z "$WSL_DISTRO_NAME" ]; then
    echo "Not running in WSL, installing VSCode and Chrome..."

    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y ./google-chrome-stable_current_amd64.deb
    rm google-chrome-stable_current_amd64.deb

    wget -O code-latest.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    sudo apt install -y ./code-latest.deb
    rm code-latest.deb
fi

# install latest git version
echo "installing latest git..."
sudo add-apt-repository -y ppa:git-core/ppa
sudo apt update
sudo apt install -y git

# set up git and ssh
echo "configuring Git and SSH..."

if [ -f .env ]; then
    source .env
fi

if [ -z "$GIT_USER" ]; then
    read -p "Enter Git Username: " GIT_USER
fi
if [ -z "$GIT_EMAIL" ]; then
    read -p "Enter Git Email: " GIT_EMAIL
fi

git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"


# zsh and oh-my-zsh
echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
chsh -s $(which zsh) $USER

# zsh-syntax-highlighting
echo "Installing zsh-syntax-highlighting..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting)/' ~/.zshrc

# starship prompt because p10k is no longer maintained :/
echo "Installing Starship..."
curl -sS https://starship.rs/install.sh | sh -s -- -y
echo 'eval "$(starship init zsh)"' >> ~/.zshrc
mkdir -p ~/.config
starship preset nerd-font-symbols -o ~/.config/starship.toml


# generate ssh key
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    echo "Generating SSH key..."
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$HOME/.ssh/id_ed25519" -N ""
    
    echo "ACTION REQUIRED: Add this public key to GitHub:"
    cat "$HOME/.ssh/id_ed25519.pub"
    echo ""
    read -p "press Enter after adding the key to GitHub..."
    
    echo "Testing SSH connection to GitHub..."
    ssh -T git@github.com || true
    echo "SSH key setup complete!"
else
    echo "SSH key exists. Skipping generation."
fi

# add ssh-agent to zshrc
echo '' >> "$HOME/.zshrc"
echo '# Start SSH agent' >> "$HOME/.zshrc"
echo 'if [ -z "$SSH_AUTH_SOCK" ]; then' >> "$HOME/.zshrc"
echo '  eval "$(ssh-agent -s)" > /dev/null' >> "$HOME/.zshrc"
echo '  ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null' >> "$HOME/.zshrc"
echo 'fi' >> "$HOME/.zshrc"


# sdkman, java
echo "Installing sdkman and java..."
curl -s "https://get.sdkman.io" | bash
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java

# nvm, node
echo "Installing nvm and node.js..."

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install --lts
nvm use --lts

echo 'export NVM_DIR="$HOME/.nvm"' >> "$HOME/.zshrc"
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$HOME/.zshrc"
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> "$HOME/.zshrc"

echo "setup complete!"
echo "log out and log back in for all changes to take effect or close and reopen the terminal if using WSL."