#!/bin/bash
#######################################################################################################
## Script to configure a raspberry for production status monitoring
## It displays a web page in kiosk mode with production status information
## to exit kiosk mode press [ctrl] + F4
##
## Script created 23.11.2021 by Marc Wenger
## Updated on 01.12.2021 to user permanent environment vars and add script to modify web pages
##
## Usage ./SetupRPI_productionStat.sh
## Usage with parameters: ./SetupRPI_productionStats.sh -wallpapeerpath "/home/pi" -statusurl "https://www.wmnetlab.ch"
##
#######################################################################################################
## TODO
# check autorefresh of data in browser
# Broken apt run those commands:
# sudo rm -rf /var/lib/apt/lists/*
# sudo apt-get clean
# sudo apt-get update
# sudo apt-get upgrade --fix-missing
###### PARAMETERS###############################################################################
# Parameters can be changed here directly or overwritten by command line arguments using -varname "VALUE"
wallpaperpath=/home/pi    #change to /home/pi
staturl="http://app.ccsholding.com/intranet/SMT/"
blackurl="/home/pi/black.html"
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

# Updating the system first
#echo -e '\e[36m'"Please be patient while the system will be updated first... this can take about 20 minutes..."'\e[0m'
#sudo apt update -y
#sudo apt upgrade -y 

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
sudo apt update -y
sudo apt install -y unclutter figlet imagemagick
sudo apt-mark hold chromium-browser
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

echo "$compname" | figlet | sudo tee -a /etc/motd
# Prevent screensaver and open webpage at boot
echo '@xset s off' | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart
echo '@xset -dpms' | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart
echo '@xset s noblank' | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart
echo '@unclutter -idle 0' | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart
echo "/usr/bin/chromium-browser --kiosk --disable-restore-session-state -disable-features=TranslateUI --disable-session-crashed-bubble --check-for-update-interval=2592000 --app=\$STATURL" | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart
sudo timedatectl set-timezone Europe/Zurich
sudo cp $wallpaperpath/GPV_Wallpaper.png /usr/share/plymouth/themes/pix/splash.png
# Create html file with black backgroound
echo -e "<!DOCTYPE html> \n <html>\n <head>\n <title>Pause</title>\n </head>\n <body style=\"background-color:black;\">\n </body></html>" | tee $blackurl

#setting environment variables
echo STATURL=$staturl | sudo tee -a /etc/environment
echo BLACKURL=$blackurl | sudo tee -a /etc/environment

# Add crontab entries
echo -e '\e[36m'"Adding crontab entries..."'\e[0m'
# echo -e "$(sudo crontab -l 2>/dev/null)\n 45 5 * * 1,2,3,4,5 /sbin/shutdown -r now" | sudo crontab -
echo -e "$(crontab -l 2>/dev/null)\n # m h  dom mon dow   command\n 50 05 * * 1,2,3,4,5 /bin/sed -i \"s,\$BLACKURL,\$STATURL,g\" /etc/xdg/lxsession/LXDE-pi/autostart && /sbin/reboot\n 10 22 * * 1,2,3,4,5 /bin/sed -i \"s,\$STATURL,\$BLACKURL,g\" /etc/xdg/lxsession/LXDE-pi/autostart && /sbin/reboot" | sudo crontab -

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
# remove the welcome splash screen at next reboot
echo -e '\e[36m'"Removing welcome to raspberry program from startup..."'\e[0m'
sudo apt purge -y piwiz
echo -e '\e[36m'"Do you want to update pi user password? (y/n)"'\e[0m'
read pipass
if [[ "$(echo $pipass | tr '[:upper:]' '[:lower:]')" == "y" ]]; then passwd; fi
echo -e '\e[36m'"Do you want to update root password? (y/n)"'\e[0m'
read rootpass
if [[ "$(echo $rootpass | tr '[:upper:]' '[:lower:]')" == "y" ]]; then sudo passwd; fi
echo -e '\e[36m'"\nscript ended.... \n"'\e[0m'
echo "Creating modification script to manage URL.."
changestaturl="IyEvYmluL2Jhc2gKIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMj\
IyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIwojIyBTY3JpcHQgdG8gY29uZmlndXJlIGEgcmFzcGJlcnJ5IGZvciBwcm9kdWN0aW9uIHN0YXR1\
cyBtb25pdG9yaW5nCiMjIEl0IGRpc3BsYXlzIGEgd2ViIHBhZ2UgaW4ga2lvc2sgbW9kZSB3aXRoIHByb2R1Y3Rpb24gc3RhdHVzIGluZm9ybWF0aW9uCiMjIHRvIGV4aXQga2lvc2sgbW9kZSBwcmVz\
cyBbY3RybF0gKyBGNAojIwojIyBTY3JpcHQgY3JlYXRlZCAxLjEyLjIwMjEgYnkgTWFyYyBXZW5nZXIKIyMgCiMjIFVzYWdlIC4vR1BWX0NoYW5nZVN0YXRVUkwuc2gKIyMgU2lsZW50IHJ1bjogLi9H\
UFZfQ2hhbmdlU3RhdFVSTC5zaCAtbmV3c3RhdHVybCAiaHR0cDovL25ld3VybC5jaCIgLXMgMQojIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMj\
IyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjCnN0YXR1cmw9JFNUQVRVUkwKYmxhY2t1cmw9JEJMQUNIVVJMCiMgUmVhZCBwYXJhbWV0ZXJzIGZyb20gY29tbWFuZCBs\
aW5lCndoaWxlIFsgJCMgLWd0IDAgXTsgZG8KCiAgIGlmIFtbICQxID09ICoiLSIqIF1dOyB0aGVuCiAgICAgICAgcGFyYW09IiR7MS8tL30iCiAgICAgICAgZGVjbGFyZSAkcGFyYW09IiQyIgogICBm\
aQoKICBzaGlmdApkb25lCgppZiBbWyAkRVVJRCAtZXEgMCBdXTsgdGhlbgogICBlY2hvIC1lICdcZVszMW0nICJQbGVhc2UgcnVuIHRoZSBzY3JpcHQgYXMgcGkgYW5kIE5PVCByb290ISAgLi4uZXhp\
dGluZyBzY3JpcHQuLi4uIidcZVswbScKICAgZXhpdCAxCmZpCgppZiBbWyAkcyAtbmUgMSBdXTsgdGhlbiAKCWVjaG8gLWUgJ1xlWzQ2bScnXGVbMzBtJyJXZWxjb21lIHRvIFVSTCBjaGFuZ2Ugd2l6\
YXJkIGZvciB0aGUgc3RhdCBzaXRlIC4uLiAiJ1xlWzBtJwoJY29uZmlybXVybD0ibiIKCXdoaWxlIFtbICIkY29uZmlybXVybCIgIT0gInkiIF1dCglkbwoJCQllY2hvICJQbGVhc2UgaW5zZXJ0IHRo\
ZSBuZXcgVVJMIGZvciB0aGUgc3RhdGlzdGljcyB3ZWIgcGFnZToiCgkJCWVjaG8gImFjdHVhbCB3ZWJwYWdlOiAkc3RhdHVybCIKCQkJcmVhZCBuZXdzdGF0dXJsCgkJCWVjaG8gLWUgJ1xlWzM2bSci\
UGxlYXNlIGNvbmZpcm0gc3RhdCBVUkw6ICRuZXdzdGF0dXJsICh5L24pIidcZVswbScKCQkJcmVhZCBjb25maXJtdXJsCgkJCWNvbmZpcm11cmw9JChlY2hvICRjb25maXJtdXJsIHwgdHIgJ1s6dXBw\
ZXI6XScgJ1s6bG93ZXI6XScpCglkb25lCmZpCgppZiBbWyAiJG5ld3N0YXR1cmwiID1+ICJodHRwIi4qIjovLyIuKiBdXTsgdGhlbgogICAgICAgIGlmIFtbICRzIC1uZSAxIF1dOyB0aGVuIGVjaG8g\
Ik9LLCB2YWxpZCBVUkwiOyBmaQplbHNlCiAgICAgICAgZWNobyAiSW52YWxpZCBVUkwgZXhpdGluZy4uLiIKICAgICAgICBleGl0IDEKZmkKCiMgVXBkYXRlIGVudmlyb25tZW50IHZhcnMgYW5kIGF1\
dG9zdGFydCBmaWxlCnN1ZG8gc2VkIC1pICJzLCRTVEFUVVJMLCRuZXdzdGF0dXJsLGciIC9ldGMvZW52aXJvbm1lbnQKI3N1ZG8gc2VkIC1pICJzLC4qL3Vzci9iaW4vY2hyb21pdW0tYnJvd3NlciAt\
LWtpb3NrIC0tZGlzYWJsZS1yZXN0b3JlLXNlc3Npb24tc3RhdGUuKiwvdXNyL2Jpbi9jaHJvbWl1bS1icm93c2VyIC0ta2lvc2sgLS1kaXNhYmxlLXJlc3RvcmUtc2Vzc2lvbi1zdGF0ZSAtZGlzYWJs\
ZS1mZWF0dXJlcz1UcmFuc2xhdGVVSSAtLWRpc2FibGUtc2Vzc2lvbi1jcmFzaGVkLWJ1YmJsZSAtLWNoZWNrLWZvci11cGRhdGUtaW50ZXJ2YWw9MjU5MjAwMCAgJG5ld3N0YXR1cmwsIiAvZXRjL3hk\
Zy9seHNlc3Npb24vTFhERS1waS9hdXRvc3RhcnQKaWYgW1sgJHMgLW5lIDEgXV07dGhlbgoJZWNobyAidGhlIG5ldyBzdGF0aXN0aWMgd2Vic2l0ZSB3aWxsIGJlIGFwcGxpZWQgYWZ0ZXIgcmVib290\
IgoJZWNobyAkbmV3c3RhdHVybAoJZWNobyAtZSAnXGVbMzZtJyJSZWJvb3Qgbm93PyAoeS9uKSInXGVbMG0nCglyZWFkIHJlYgoJaWYgW1sgIiRyZWIiID09ICJ5IiBdXTsgdGhlbiBzdWRvIHNodXRk\
b3duIC1yIG5vdzsgZmkKZWxzZQoJZWNobyAiTmV3IFVSTCBzdWNjZXNmdWwgcmVwbGFjZWQuIFJlYm9vdGluZy4uLiIKCXN1ZG8gc2h1dGRvd24gLXIgbm93CmZpIA=="
echo "$changestaturl" | base64 -d > "$wallpaperpath/GPV_ChangeStatURL.sh"
chmod +x $wallpaperpath/GPV_ChangeStatURL.sh
echo -e '\e[36m'"To change the statistic page URL please un the GPV_ChangeStatURL.sh script \n"'\e[0m'
# export DISPLAY=:0 && pcmanfm --set-wallpaper "$wallpaperpath/GPV_Wallpaper.png"
cp $wallpaperpath/GPV_Wallpaper.png $wallpaperpath/temple.png
mogrify -format jpg $wallpaperpath/temple.png
sudo mv /usr/share/rpd-wallpaper/temple.jpg /usr/share/rpd-wallpaper/temple1.jpg
sudo mv $wallpaperpath/temple.jpg /usr/share/rpd-wallpaper/temple.jpg
echo -e '\e[36m'"Reboot now? (y/n)"'\e[0m'
read reb
if [[ "$reb" == "y" ]]; then sudo shutdown -r now; fi
