#!/bin/bash

TIME_RUN_GUI=$(date +%s)

echo "##########################################################"
echo "####    Installing the GUI tools (XFCE and X2Go)      ####"
echo "##########################################################"

# Update packages (important if the Ubuntu version has been released recently)
apt-get update

echo "=> Removing all Display Managers except 'lightdm'"
DEBIAN_FRONTEND=noninteractive apt-get remove -y gdm3 sddm 
DEBIAN_FRONTEND=noninteractive apt-get autoremove -y 
echo "=> Forcing installation of 'lightdm' as default Display Manager"
rm -rf /etc/X11/default-display-manager
echo "/usr/sbin/lightdm" | tee /etc/X11/default-display-manager
DEBIAN_FRONTEND=noninteractive apt-get install -yq lightdm
DISPLAY_MNGR="$(cat /etc/X11/default-display-manager)"
printf "=> Default Display Manager: $${DISPLAY_MNGR} \n"

# Check if XFCE4 and X3Go Server are installed
dpkg-query -W xfce4 x2goserver > /dev/null 2>&1
GUI_STATUS="$${?}"

# If GUI_STATUS=0, then both pkgs have been installed
# If GUI_STATUS=1, then at least one has not been installed
if [ $${GUI_STATUS} -ne 0 ]; then
    echo "=> The XFCE4 or X2Go Server have not been installed (GUI_STATUS=$${GUI_STATUS})."

    echo "=> Installing XFCE4"
    DEBIAN_FRONTEND=noninteractive apt-get install -yq xfce4
    apt-mark hold xfce4

    echo "=> Installing X2Go Server"
    add-apt-repository -y ppa:x2go/stable
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -yq x2goserver x2goserver-xsession
    apt-mark hold x2goserver
else
    echo "=> Seems the XFCE4 and X2Go Server have already been installed (GUI_STATUS=$${GUI_STATUS})."
fi
echo "=> Checking XFCE4 and X2Go Server"
dpkg-query -W xfce4 x2goserver

printf "\t Duration: $((($(date +%s)-$${TIME_RUN_GUI}))) seconds.\n\n"
