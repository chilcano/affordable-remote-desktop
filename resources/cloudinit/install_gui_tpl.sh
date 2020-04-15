#!/bin/bash

TIME_RUN_GUI=$(date +%s)

echo "##########################################################"
echo "####         Installing the GUI & Remote Tools        ####"
echo "##########################################################"

# Check if XFCE4 and X3Go Server are installed
dpkg-query -W xfce4 x2goserver > /dev/null 2>&1
GUI_STATUS="$${?}"

# If GUI_STATUS=0, then both pkgs have been installed
# If GUI_STATUS=1, then at least one has not been installed
if [ $${GUI_STATUS} -ne 0 ]; then
    echo "=> The XFCE4 or X2Go Server have not been installed (GUI_STATUS=$${GUI_STATUS})."

    echo "=> Installing XFCE4"
    apt-get install -y xfce4
    apt-mark hold xfce4

    echo "=> Installing X2Go Server"
    add-apt-repository -y ppa:x2go/stable
    apt-get update
    apt-get install -y x2goserver x2goserver-xsession
    apt-mark hold x2goserver
else
    echo "=> Seems the XFCE4 and X2Go Server have already been installed (GUI_STATUS=$${GUI_STATUS})."
fi
echo "=> Checking XFCE4 and X2Go Server installation."
dpkg-query -W xfce4 x2goserver

printf "\t** Duration of GUI tools installation: $((($(date +%s)-$${TIME_RUN_GUI}))) seconds.\n\n"
