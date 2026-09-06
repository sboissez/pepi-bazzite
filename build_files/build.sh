#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

dnf5 install -y gnome-shell-extension-dash-to-dock

# Ghostty terminal. No Flatpak or Homebrew formula exists, so it comes from the
# scottames COPR; the repo is disabled again so it does not stay enabled on the
# running system. Its config is managed by mise (github.com/sboissez/mise).
dnf5 -y copr enable scottames/ghostty
dnf5 install -y ghostty
dnf5 -y copr disable scottames/ghostty

dnf5 remove -y waydroid
dnf5 remove -y gnome-shell-extension-gsconnect
dnf5 remove -y input-remapper
dnf5 remove -y rom-properties

# Remove other built-in GNOME Shell extensions we don't want.
# These aren't RPM packages - Bazzite builds them straight into
# /usr/share/gnome-shell/extensions/ (see ublue-os/bazzite's
# build_files/build-gnome-extensions), so we just delete the directories.
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
rm -rf /usr/share/fish

# Install our custom Flatpaks (Discord, Zed, Transmission) on first boot.
# /var isn't part of the committed image, so `flatpak install` can't run
# here during build - it has to happen post-boot once /var/lib/flatpak
# exists. See system_files/usr/share/pepi-flatpaks/flatpaks for the list.
systemctl enable pepi-install.service
hostnamectl set-hostname pepi
