# My dev setup

A script that automates a lot of boring setup i'd have to do manually on a fresh Windows + WSL2 (or Ubuntu/PopOS) Install. I made this mainly for my personal use but maybe someone else enjoys my setup.

## What it installs

- **Shell**: Zsh + Oh My Zsh + zsh-syntax-highlighting
- **Prompt**: Starship (with nerd-font-symbols preset)
- **Dev tools**: Latest Git version, latest Java LTS (via SDKMAN), Node.js LTS (via nvm)
- **SSH**: Generates ed25519 key and configures ssh-agent (doesn't overwrite existing SSH keys)

## Usage

```bash
git clone https://github.com/selisterdev/dev-setup.git
cd dev-setup

# Optional: create .env file to skip prompts
cp .env.example .env
# edit .env with your GitHub info

chmod +x setup.sh
./setup.sh
```

The script will ask for your Git username and email (unless you set them in `.env`), then it will generate an SSH key and show you the public key (it will pause so you can go over to GitHub and add it there), and it'll install everything else automatically


## After running

1. Log out and log back in (for shell changes to take effect)
2. Done

## Notes

- Tested on PopOS 24.04 COSMIC and Ubuntu 24.04 LTS on Windows with WSL2
- Uses `set -e` so it'll stop on any error
- won't overwrite existing SSH keys
