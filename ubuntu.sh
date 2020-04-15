#!/usr/bin/env sh
###############################################################################
### Author:       Valerio Casalino                                          ###
### Description:  Install basic software in ubuntu-like systems             ###
###############################################################################

### Global variables
UBUNTU_CODENAME=$( lsb_release -cs )

### Errors
errmsg() { printf "\e[31m%s\e[0m\\n" "$1"; } 
err() { errmsg "$1"; return 1; }

### Check if root
[ $EUID -ne 0 ] && errmsg "Please, run as root" && exit 1

### Functions
# Apt mirror:// method to get apt choose the best mirror
setMirrors() {
  printf "deb mirror://mirrors.ubuntu.com/mirrors.txt %s main restricted universe multiverse\\n" "$UBUNTU_CODENAME" | tee /etc/apt/sources.list
  printf "deb mirror://mirrors.ubuntu.com/mirrors.txt %s-updates main restricted universe multiverse\\n" "$UBUNTU_CODENAME" | tee -a /etc/apt/sources.list
  printf "deb mirror://mirrors.ubuntu.com/mirrors.txt %s-backports main restricted universe multiverse\\n" "$UBUNTU_CODENAME" | tee -a /etc/apt/sources.list
  printf "deb mirror://mirrors.ubuntu.com/mirrors.txt %s-security main restricted universe multiverse\\n" "$UBUNTU_CODENAME" | tee -a /etc/apt/sources.list
}

# Install nerd fonts... It will require a while
installSourceCodePro() {
  version="1.010"
  out=$( mktemp -d )
  wget "https://github.com/downloads/adobe/source-code-pro/SourceCodePro_FontsOnly-$version.zip" -O "$out"
  unzip "$out" -d /tmp/scp
  for i in /home/*; do mkdir -p "$i/.local/share/fonts"; cp /tmp/scp/ "$i/.local/share/fonts/"; fc-cache -f -v; done
  rm -rf "$out"
}

# Zsh workflow
installZsh() {
  apt install -y zsh zsh-syntax-highlighting zsh-autosuggestions || err "zsh workflow not installed"
  for i in /home/*; do cp ./resources/.zshrc "$i"; done
}

# Use alacritty.yml in the repository
installAlacritty() {
  add-apt-repository "ppa:mmstick76/alacritty" && apt install -y alacritty || err "Unable to install alacritty"
  for i in /home/*; do mkdir -p "$i/.config/alacritty" && cp ./resources/alacritty.yml "$i/.config/alacritty"; done
}

# Use xterm as default?
installXtermConfigs() {
  for i in /home/*; do cp ./resources/.Xresources "$i"; done && errmsg "Restart (or logout) required"
}

# Visual Studio Code installation
installVScode() {
  curl -s "https://packages.microsoft.com/keys/microsoft.asc" | gpg --dearmor > /tmp/packages.microsoft.gpg
  install -o root -g root -m 644 /tmp/packages.microsoft.gpg /usr/share/keyrings/
  sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
  apt -y update && apt install -y code || err "Unable to install VScode"
}

# xfce4 with some customizations
installXfceConfigs() {
  xfce4-panel-profiles load ./resources/xfce4/panel.tar.bz2
  for i in /home/*; do cp ./resources/xfce4/xfce4-keyboard-shortcuts.xml "$i/.config/xfce4/xfce-perchannel-xml/"; done
}

# Commands from https://brave-browser.readthedocs.io/en/latest/installing-brave.html#linux
installBrave() { 
  curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add - || err "Failed to add brave gpg signature"
  echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list || err "Failed to add brave to repository sources"
  apt -y update && apt install -y brave-browser || err "Failed to apt install brave"
  # Enable hardware acceleration
  for i in /home/*; do cp ./resources/chromium-flags.conf "$i/.config/brave-flags.conf"; done
}

### Actual script
printf "Welcome to this installation!\\nLet's start with your mirrors...\\n"
setMirrors || errmsg "Mirrors update failure"
printf "Done!\\nNow let's update your repositories and upgrade the system\\n"
apt -u update && apt -y upgrade && apt -y autoremove && apt -y autoclean || errmsg "Repos couldn't be updated/upgraded"
printf "Installing some required package\\n"
apt install -y apt-transport-https curl xterm || { errmsg "Failed to get pre-requisites"; exit 1; }
printf "Installing starship (https://starship.rs/)\\n"
curl -fsSL https://starship.rs/install.sh | bash && for i in /home/*; do cp ./resources/starship.toml "$i/.config/"; done
printf "Installing zsh and configs\\n"
installZsh && installSourceCodePro || exit 1
printf "Installing Brave, VS Code and alacritty\\n"
installAlacritty && installBrave && installVScode || exit 1
printf "Installing configs\\n"
installXfceConfigs && installXtermConfigs || exit 1
printf "It is done!!"
