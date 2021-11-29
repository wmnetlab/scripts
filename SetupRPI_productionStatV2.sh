#!/bin/bash
#######################################################################################################
## Script to configure a raspberry for production status monitoring
## It displays a web page in kiosk mode with production status information
## to exit kiosk mode press [ctrl] + F4
##
## Script created 23.11.2021 by Marc Wenger
##
## Usage ./SetupRPI_productionStat.ch
## Usage with parameters: ./SetupRPI_productionStats.sh -wallpapeerpath "/home/pi" -statusurl "https://www.wmnetlab.ch"
##
#######################################################################################################
## TODO
# setup correct start and stop times
# check autorefresh of data in browser

###### PARAMETERS###############################################################################
# Parameters can be changed here directly or overwritten by command line arguments using -varname "VALUE"
wallpaperpath=/home/pi    #change to /home/pi
staturl="https://inttargitapp.int.gpv.dk/anywhere"
###### END PARAMETERS ##########################################################################
# Read parameters from command line
while [ $# -gt 0 ]; do

   if [[ $1 == *"-"* ]]; then
        param="${1/-/}"
        declare $param="$2"
   fi

  shift
done

echo -e '\e[46m''\e[30m'"Welcome to the installation script for Production status monitor..."'\e[0m'
if [[ $EUID -eq 0 ]]; then
   echo -e '\e[31m' "Please run the script as pi and NOT root!  ...exiting script...."'\e[0m'
   exit 1
fi
# check if URL is a valid http url
if [[ "$staturl" =~ "http".*"://".* ]]; then
	echo "OK, staturl seems a valid URL: $staturl"
else
	echo -e '\e[31m'"Invalid staturl detected: $staturl \n .... exiting script...."'\e[0m'
	exit 1
fi
confirmcompname="n"
while [[ "$confirmcompname" != "y" ]]
do
	echo -e '\e[36m'"Please insert new computername:"'\e[0m'
	read compname
	echo -e '\e[36m'"Please confirm name $compname (y/n)"'\e[0m'
	read confirmcompname
	confirmcompname=$(echo $confirmcompname | tr '[:upper:]' '[:lower:]')
done

NEW_HOSTNAME="$compname"
CUR_HOSTNAME=$(cat /etc/hostname)

# Display current hostname
echo "the current hostname is $CUR_HOSTNAME"
sudo hostnamectl set-hostname $NEW_HOSTNAME
sudo hostname $NEW_HOSTNAME
sudo sed -i "s/$CUR_HOSTNAME/$NEW_HOSTNAME/g" /etc/hosts
sudo sed -i "s/$CUR_HOSTNAME/$NEW_HOSTNAME/g" /etc/hostname

echo -e '\e[36m'"New hostname has been set: $NEW_HOSTNAME"'\e[0m'
# Install unclutter to hide mouse
echo "installing required components"
sudo apt install -y unclutter
# Generate GPV_Wallpaper.png
wallpaper="iVBORw0KGgoAAAANSUhEUgAAB4AAAASwCAMAAAAt7qfEAAAAsVBMVEUANDoANToANTsANjsANzsANzwAODwAOTwAOT0AOj0AOz0APD4APT4APj4APj8APz8AP0AAQD8AQEAAQUAAQUEAQkAAQ0AAQ0EA\
REEAREIARUEARUIARUMARkIARkMAR0IAR0MASEMASEQASUMASUQASUUASkMASkQASkUAS0QAS0UAS0YATEYATUcATkcAT0gAUEgAUUkAUkkAU0oAVEoAVUsAVksAV0wAWEwAWUwAWU0EGbZRAAAThElE\
QVR42u3Za09aWRiGYTkUFTxWKVIHWqxaZqRUqvX0/3/YfJhkUnbYzbbZvksX1/X5iQlvVnJnx40NAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
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\
9Fd/AdBf/dVfAPRXfwHQX/3VXwDS9vdUf/UXAP3VXwD0V3/1F0B/9Vd/AdBf/dVfAP3VX/0FIHF//zQf+qu/APqrv/oLgP7qr/4C6K/+6i8A+qu/AOiv/uovAHX196Xzob/6C6C/+qu/AOiv/uovgP7q\
r/4CoL/6C4D+6q/+AqC/+guA/uqv/gKgv/oLgP7qr/4C6K/+6i8A+qu/+gugv/qrvwDor/4CoL/6q78A6K/+AqC/+qu/AOiv/gKgv/r7i57+Auiv/uovAPqrvwDor/7qLwD6q78A6K/+6i8A+qu/AOjv\
2vV3X38B0F/9BUB/9Vd/AfRXf/UXAP3VX/0F0F/9XfJBfwHQ3/D+9vUXAP3VXwD0V3/1FwD91V8A9Fd/9RdAf/VXfwHQ38T9PdFfAPRXf/UXQH/1V38B0F/9BUB/9Vd/AdBf/QVAf/VXfwFYt/429RcA\
/Y3v70h/AdBf/dVfAP3VX/0FQH/1V38B9Fd/9RcA/dVfAPQ3cX8n+guA/uqv/gKgv/oLgP7qr/4C6K/+6i8A+qu/+gugv2n727nUX/0F0F/91V8A9Fd/AdBf/dVfAPRXfwHQX/3VXwDS9ndbf/UXQH/1\
V38B0F/91V8A/dVf/QVAf/UXAP3VX/0FIHF/d/RXfwEI729Pf/UXAP3VXwD0V3/1FwD9fTv9HekvgP7qb3x/mx4rgP7qb139PWnoL4D+hv37Un/1F0B/9Vd/AdBf/dVfAP3VX/0FQH/1FwD91d+VjvQX\
gHJ9/X2Z/vb1FwD91V8A9Fd/9RdAf/VXfwHQX/3VXwD91V/9BUB/9RcA/dVf/QVAf/UXAP3VX/0FQH9r6O++/gKgv/oLgP7qr/4CoL/6C4D+6q/+AqC/+st//gXpCDcKWfH2cgAAAABJRU5ErkJggg=="

echo "$wallpaper" | base64 -d > "$wallpaperpath/GPV_Wallpaper.png"
echo "wallpaper created"

echo -e '\e[36m'"Settings display options: (desktop background, prevent screensaver, autostart of webbroswer at boot)"'\e[0m'
export DISPLAY=:0.0
pcmanfm --set-wallpaper "$wallpaperpath/GPV_Wallpaper.png"

# Prevent screensaver and open webpage at boot
echo '@xset s off' | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart
echo '@xset -dpms' | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart
echo '@xset s noblank' | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart
echo '@unclutter -idle 0' | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart
echo "/usr/bin/chromium-browser --kiosk --disable-restore-session-state $staturl" | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart

# Create html file with black backgroound
echo -e "<!DOCTYPE html> \n <html>\n <head>\n <title>Pause</title>\n </head>\n <body style=\"background-color:black;\">\n </body></html>" | tee /home/pi/black.html

# Add crontab entries
echo -e '\e[36m'"Adding crontab entries..."'\e[0m'
echo -e "$(sudo crontab -l 2>/dev/null)\n 45 5 * * 1,2,3,4,5 /sbin/shutdown -r now" | sudo crontab -
# echo -e "$(sudo crontab -l 2>/dev/null)\n 10 22 * * 1,2,3,4,5 service rpi_no_hdmi start" | sudo crontab -
echo -e "$(crontab -l 2>/dev/null)\n 10 22 * * 1,2,3,4,5 pkill -o chromium" | crontab -
echo -e "$(crontab -l 2>/dev/null)\n 11 22 * * 1,2,3,4,5 /usr/bin/chromium-browser --kiosk --disable-restore-session-state /home/pi/black.html" | crontab -

# Mute sound - Needed only on Raspian with bullseye
#echo -e '\e[36m'"Muting sound output...\n"'\e[0m'
#amixer sset Master 0
#amixer sset Master off
#sudo alsactl store
echo -e '\e[36m'"Do you want to configure VNC server? (y/n)"'\e[0m'
read installvnc
if [[ "$(echo $installvnc | tr '[:upper:]' '[:lower:]')" == "y" ]]; then 
	sudo systemctl enable vncserver-x11-serviced.service
	echo -e "Authentication=VncAuth" | sudo tee -a /root/.vnc/config.d/vncserver-x11
	echo -e '\e[36m'"Please enter vnc connection password and verify"'\e[0m'
	sudo vncpasswd -service
	echo "Starting vnc server....."
	sudo systemctl start vncserver-x11-serviced.service
fi


echo -e '\e[36m'"Do you want to update pi user password? (y/n)"'\e[0m'
read pipass
if [[ "$(echo $pipass | tr '[:upper:]' '[:lower:]')" == "y" ]]; then passwd; fi
echo -e '\e[36m'"Do you want to update root password? (y/n)"'\e[0m'
read rootpass
if [[ "$(echo $rootpass | tr '[:upper:]' '[:lower:]')" == "y" ]]; then sudo passwd; fi
echo -e '\e[36m'"\nscript ended.... \n"'\e[0m'

echo -e '\e[36m'"Reboot now? (y/n)"'\e[0m'
read reb
if [[ "$reb" == "y" ]]; then sudo shutdown -r now; fi
