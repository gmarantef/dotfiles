#!/bin/sh
# vim: ft=sh
set -e

# Sudo at start
echo "Request sudo permissions..."
sudo -v

# Keep alive sudo
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_PID=$!

# Install flatpak for packages inside brew bundle
if ! command -v flatpak >/dev/null 2>&1; then
    echo "Installing Flatpak ..."
    sudo apt update
    sudo apt install -y flatpak
fi

# Add flathub repository
if ! flatpak remote-list | grep -q flathub; then
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Install Homebrew packages if brew is available
if command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew packages..."
    brew bundle --file="$HOME/.Brewfile"
fi

# Install Google Chrome
if ! command -v google-chrome >/dev/null 2>&1; then
    echo "Installing Google Chrome..."

    if [ ! -f /usr/share/keyrings/google-chrome.gpg ]; then
        wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | \
            sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg
    fi

    if [ ! -f /etc/apt/sources.list.d/google-chrome.list ]; then
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] \
http://dl.google.com/linux/chrome/deb/ stable main" | \
            sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null
    fi

    sudo apt update
    sudo apt install -y google-chrome-stable
fi

# Configure zsh only if it exists (installed via brew bundle)
if command -v zsh >/dev/null 2>&1; then
    ZSH_PATH="$(command -v zsh)"

    # Install Oh-My-ZSH if not exists
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing Oh My Zsh..."
        RUNZSH=no CHSH=no sh -c \
            "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    # Only ask if it's not already the default shell
    if [ "$SHELL" != "$ZSH_PATH" ]; then
        if [ -t 0 ]; then
            printf "zsh is installed. Set it as your default shell? [Y/n] "
            read -r answer
            answer=${answer:-Y}

            case "$answer" in
                Y|y|yes|YES)
                    echo "Setting zsh as default shell..."
                    chsh -s "$ZSH_PATH"
                    ;;
                *)
                    echo "Keeping current shell."
                    ;;
            esac
        else
            echo "Non-interactive mode detected. Skipping shell change."
        fi
    fi
fi

# Kill manually sudo
kill "$SUDO_PID" 2>/dev/null

echo "Bootstrap completed successfully."

