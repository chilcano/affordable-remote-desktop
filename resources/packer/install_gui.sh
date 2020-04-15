#!/bin/bash

echo "##########################################################"
echo "####         Installing the GUI & Remote Tools        ####"
echo "##########################################################"

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update

echo "==> Installing XFCE4"
sudo apt-get install -y xfce4
sudo apt-mark hold xfce4

echo "==> Installing X2Go Server"
sudo add-apt-repository -y ppa:x2go/stable
sudo apt-get update
sudo apt-get install -y x2goserver x2goserver-xsession
sudo apt-mark hold x2goserver
#apt-get install x2gomatebindings  # if you use MATE/mubuntu
#apt-get install x2golxdebindings  # if you use LXDE/lubuntu
