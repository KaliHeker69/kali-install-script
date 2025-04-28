#!/bin/bash

# List of software to check and install via apt
SOFTWARE=(
    "git"
    "curl"
    "vim"
    "nmap"
    "python3"
    "dirsearch"
    "wpscan"
    "gobuster"
    "john"
    "ffuf"
    "hashcat"
    "sqlmap"
)

# Function to check and install software via apt
install_software() {
    for pkg in "${SOFTWARE[@]}"; do
        if ! dpkg -l | grep -qw "$pkg"; then
            echo "$pkg is not installed. Installing..."
            sudo apt-get update
            sudo apt-get install -y "$pkg"
        else
            echo "$pkg is already installed."
        fi
    done
}

# Install zip2john (part of john package, symlink if missing)
install_zip2john() {
    if ! command -v zip2john &> /dev/null; then
        if [ -f /usr/share/john/zip2john.py ]; then
            sudo ln -s /usr/share/john/zip2john.py /usr/local/bin/zip2john
            sudo chmod +x /usr/local/bin/zip2john
            echo "zip2john symlink created."
        else
            echo "zip2john.py not found. Please check john installation."
        fi
    else
        echo "zip2john is already installed."
    fi
}

# Install stegseek (download .deb and install if not present)
install_stegseek() {
    if ! command -v stegseek &> /dev/null; then
        echo "stegseek is not installed. Installing..."
        wget -q https://github.com/RickdeJager/stegseek/releases/latest/download/stegseek-0.6-1.deb -O /tmp/stegseek.deb
        sudo apt-get install -y ./tmp/stegseek.deb
        rm /tmp/stegseek.deb
    else
        echo "stegseek is already installed."
    fi
}

# Install gitdumper (download if not present)
install_gitdumper() {
    if ! command -v gitdumper.sh &> /dev/null; then
        echo "gitdumper is not installed. Downloading..."
        sudo wget -q https://raw.githubusercontent.com/internetwache/GitTools/master/Dumper/gitdumper.sh -O /usr/local/bin/gitdumper.sh
        sudo chmod +x /usr/local/bin/gitdumper.sh
    else
        echo "gitdumper is already installed."
    fi
}

# Execute the installation functions
install_software
install_zip2john
install_stegseek
install_gitdumper