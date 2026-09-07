#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages
dnf5 install -y gnome-shell-extension-dash-to-dock


dnf5 -y copr enable scottames/ghostty
dnf5 install -y ghostty
dnf5 -y copr disable scottames/ghostty

dnf5 remove -y waydroid
dnf5 remove -y gnome-shell-extension-gsconnect
dnf5 remove -y input-remapper
dnf5 remove -y rom-properties
dnf5 remove -y ptyxis

# Remove other built-in GNOME Shell extensions we don't want.
rm -rf /usr/share/gnome-shell/extensions/burn-my-windows@schneegans.github.com
rm -rf /usr/share/gnome-shell/extensions/compiz-windows-effect@hermes83.github.com/schemas
rm -rf /usr/share/gnome-shell/extensions/desktop-cube@schneegans.github.com

rm -f /usr/bin/waydroid-launcher
rm -f /usr/share/applications/waydroid-container-restart.desktop
rm -f /usr/libexec/waydroid-container-restart
rm -f /usr/libexec/waydroid-container-start
rm -f /usr/libexec/waydroid-container-stop
rm -f /usr/libexec/waydroid-fix-controllers
rm -rf /usr/share/applications/Waydroid/

rm -f /usr/share/applications/discourse.desktop

rm -f /usr/share/fish/functions/fish_prompt.fish
rm -f /usr/share/fish/functions/fish_greeting.fish
rm -f /usr/share/fish/vendor_conf.d/bazzite-neofetch.fish

# Install our custom Flatpaks (Discord, Zed, Transmission) on first boot.
systemctl enable pepi-install.service

echo "pepi" > /etc/hostname

# Recompile the dconf system-db so our overrides (e.g. the terminal
# defaults in system_files/etc/dconf/db/distro.d/10-pepi-terminal) take
# effect without waiting for dconf-update.service to run post-boot.
dconf update
