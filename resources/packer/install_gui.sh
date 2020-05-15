#!/bin/bash

echo "=========================================================="
echo "=       Installing the GUI tools (XFCE and X2Go)         ="
echo "=========================================================="

sudo apt-get update

echo "==> Removing all Display Managers except 'lightdm'"
sudo DEBIAN_FRONTEND=noninteractive apt-get remove -y gdm3 sddm 
sudo DEBIAN_FRONTEND=noninteractive apt-get autoremove -y 
echo "==> Forcing installation of 'lightdm' as default Display Manager"
sudo rm -rf /etc/X11/default-display-manager
echo "/usr/sbin/lightdm" | sudo tee /etc/X11/default-display-manager
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq lightdm

echo "==> Installing XFCE4"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq xfce4
sudo apt-mark hold xfce4

echo "==> Installing X2Go Server"
sudo add-apt-repository -y ppa:x2go/stable
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq x2goserver x2goserver-xsession
sudo apt-mark hold x2goserver
#apt-get install x2gomatebindings  # if you use MATE/mubuntu
#apt-get install x2golxdebindings  # if you use LXDE/lubuntu
