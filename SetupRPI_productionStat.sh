#!/bin/bash
#######################################################################################################
## Script to configure a raspberry for production status monitoring
## It displays a web page in kiosk mode with production status information
##
## Script created 23.11.2021 by Marc Wenger
##
#######################################################################################################
## TODO
# webpage to open in kioskmode
# setup correct start and stop times
# check autorefresh of data in browser

###### PARAMETERS###################
wallpaperpath=/home/pi    #change to /home/pi

###### END PARAMETERS ##############
echo -e '\e[46m''\e[30m'"Welcome to the installation script for Production status monitor..."'\e[0m'
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
#####################REMOVE COMMENTS BEFORE PRODUCTION###############################################
sudo hostnamectl set-hostname $NEW_HOSTNAME
sudo hostname $NEW_HOSTNAME
sudo sed -i "s/$CUR_HOSTNAME/$NEW_HOSTNAME/g" /etc/hosts
sudo sed -i "s/$CUR_HOSTNAME/$NEW_HOSTNAME/g" /etc/hostname

echo -e '\e[36m'"New hostname has been set: $NEW_HOSTNAME"'\e[0m'

wallpaper="iVBORw0KGgoAAAANSUhEUgAAB4AAAASwCAMAAAAt7qfEAAAAsVBMVEUANDoANToANTsANjsANzsA\
NzwAODwAOTwAOT0AOj0AOz0APD4APT4APj4APj8APz8AP0AAQD8AQEAAQUAAQUEAQkAAQ0AAQ0EA\
REEAREIARUEARUIARUMARkIARkMAR0IAR0MASEMASEQASUMASUQASUUASkMASkQASkUAS0QAS0UA\
S0YATEYATUcATkcAT0gAUEgAUUkAUkkAU0oAVEoAVUsAVksAV0wAWEwAWUwAWU0EGbZRAAAThElE\
QVR42u3Za09aWRiGYTkUFTxWKVIHWqxaZqRUqvX0/3/YfJhkUnbYzbbZvksX1/X5iQlvVnJnx40N\
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
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\
WIEVGAAFVmAAFFiBFRgABVZgABRYgRUYQIEVWIEBUGAFVmAABVZgBQZAgRUYAAVWYAUGQIEVGIC3\
XOCxAiswAAqswAoMoMAKrMAAKLACA6DACqzAACiwAgOQcYH/UWAFBiBBgacKrMAAKLACA6DACqzA\
ACiwAgOgwAqswAAKHFTg7w0FVmAA4gs8V2AFBkCBFRgABVZgBQZQYAVWYAAUWIEVGECBFViBAVBg\
BQZAgWst8I+WAiswgALHF3ihwAoMoMAKrMAAKLACA6DACqzAACiwAgOgwEEF/tlRYAAUOL7AtwoM\
gAIrsAIDoMAKDIACK7ACA6DACgyAAkcVuKvAAChwfIHvFBgABVZgBQZAgRUYAAVWYAUGUGAFVmAA\
FFiBFRhAgTMu8MOeAgOgwAqswAAKrMAKDIACKzAACqzACgyAAiswAAqccYGPFRgABVZgABRYgRUY\
AAVWYAAUWIEVGAAFVmAAFDjjAlc9oAIDKLACKzAACqzACgygwAqswADUbK7ACgxAvIYCKzAACryG\
Bb5SYAAFVuAEBa56QAUGUGAFVmAAFFiBAci6wBcKrMAAJCjwVIEVGAAFVmAAFFiBQwrc8FoBFFiB\
4ws8V2AABVZgBQZAgRUYAAXe2BgrsAIDoMAKDIACK7ACA6DACgyAAiuwAgMosAIrMAAKrMAKDKDA\
tRb46EmBFRhAgeMLfKzACgygwAqswAAosAIrMIACK7ACA6DACgyAAkcV+EGBFRhAgeMLvKfACgyg\
wAqswAAosAIDoMAKrMAAKLACA6DACqzAAGRc4K4CA6DACqzAACiwAgOgwAqswAAosAIDoMAKrMAA\
CpxxgTu3CgyAAiuwAgMosAIrMAAKrMAKDKDACqzAACiwAgOgwBkXeKHAAChwfIFbCgyAAiuwAgMo\
sAIrMAAKrMAAKLACKzAAChxV4LkCA6DA8QVuKDAACqzAACiwAiswAAqswAAosAIrMAAKHFXgcwUG\
QIETFHiqwAAosAIDoMAKrMAACqzACgyAAiuwAgMosAIrMAAKrMAAKLAC13rAvxQYQIEVOEGBxwoM\
oMAKrMAAKLACA6DACqzAACiwAgOgwAqswAAosAIDoMAKrMAAKLACA6DACqzAAAqswAoMgAIrsAID\
KLACKzAACqzAACiwAiswAAqswAC85QIPFViBAVBgBVZgAAVWYAUGQIEVGAAFVmAFBkCBFRiAjAt8\
psAKDMDzNSfnq20Whp9Ldr3C7rRk976wG5TsBoXdUcluVNjtlOw+F3bbJbtJofzvSnbnnYoH7FY8\
4F7FAx55rAA5fQGf/L3abmHYL9kdFnb7JbtiV3slu1Gz0MuS3aRd+LK9XL27LPSyPSn5g9uFro5K\
dr2KB9yveMB+xQOe+AIG0N/n97eYD/3VXwD91V/9BUB/9Vd/AfRXf/UXAP3VXwD0V3/1F4Do/v5p\
PvRXfwH0V3/1FwD91V/9BdBf/dVfAPRXfwHQX/3VXwDq6u9L50N/9RdAf/VXfwHQX/3VXwD91V/9\
BUB/9RcA/dVf/QVAf/UXAP3VX/0FQH/1FwD91V/9BdBf/dVfAPRXf/UXQH/1V38B0F/9BUB/9Vd/\
AdBf/QVAf/VXfwHQX/0FQH/19xe7+gugv/qrvwDor/4CoL/6q78A6K/+AqC/+qu/AOhv4v4e6S8A\
+hve30P9BUB/9RcA/dVf/QXQX/3VXwD0V3/1F0B/9XeJ/gKgv/H9HegvAPqrvwDor/7qLwD6q78A\
6K/+6i+A/uqv/gKgv2n72zjVXwD0V3/1F0B/9Vd/AdBf/QVAf/VXfwHQX/0FQH/1V38B9Hfd+tvS\
XwD0N76/n/QXAP3VX/0F0F/91V8A9Fd/9RdAf/VXfwHQX/0FQH/T9rf9RX8B0F/91V8A9Fd/AdBf\
/dVfAP3VX/0FQH/1V38B9Ddtfze/6q/+Auiv/uovAPqrvwDor/7qLwD6q78A6K/+6i8Aafvb1V/9\
BdBf/dVfAPRXf/UXQH/1V38B0F/9BUB/9Vd/AdBf/QVg7fq7q7/P6+8H/QXQX/0N7+9AfwH0V3/1\
FwD91d//fdRfAP3V3/D+nuovgP7qr/4CENHfQ/3VXwD097X391B/AdBf/QVAf/VXfwH0V3/1FwD9\
1V/9BcjdQH/1FwD91V/9BdBf/dVfAPRXfwHQX/3VXwD0V38B0F/91V8A9Fd/AdBf/dVfAP3VX/0F\
QH9fb3939BcA/Q3v767+AqC/+guA/uqv/gKgv/oLgP7qr/4CoL/6C4D+6q/+Aujv2vW3q78A6K/+\
6i+A/uqv/gKgv/oLgP7qr/4CoL/6C4D+pu3v1039BUB/9Vd/AdBf/QVAf/VXfwH0V3/1FwD91V8A\
9Ddtf7/oLwD6q7/6C4D+6i8A+qu/+guA/uovAPqrv/oLoL+J+/tJf/UXQH/j+9vSX/0F0F/91V8A\
9Fd/AdBf/dVfAPRXfwHQX/3VXwDS9vdUf/UXAP3VXwD0V3/1F0B/9Vd/AdBf/dVfAP3VX/0FIHF/\
/zQf+qu/APqrv/oLgP7qr/4C6K/+6i8A+qu/AOiv/uovAHX196Xzob/6C6C/+qu/AOiv/uovgP7q\
r/4CoL/6C4D+6q/+AqC/+guA/uqv/gKgv/oLgP7qr/4C6K/+6i8A+qu/+gugv/qrvwDor/4CoL/6\
q78A6K/+AqC/+qu/AOiv/gKgv/r7i57+Auiv/uovAPqrvwDor/7qLwD6q78A6K/+6i8A+qu/AOjv\
2vV3X38B0F/9BUB/9Vd/AfRXf/UXAP3VX/0F0F/9XfJBfwHQ3/D+9vUXAP3VXwD0V3/1FwD91V8A\
9Fd/9RdAf/VXfwHQ38T9PdFfAPRXf/UXQH/1V38B0F/9BUB/9Vd/AdBf/QVAf/VXfwFYt/429RcA\
/Y3v70h/AdBf/dVfAP3VX/0FQH/1V38B9Fd/9RcA/dVfAPQ3cX8n+guA/uqv/gKgv/oLgP7qr/4C\
6K/+6i8A+qu/+gugv2n727nUX/0F0F/91V8A9Fd/AdBf/dVfAPRXfwHQX/3VXwDS9ndbf/UXQH/1\
V38B0F/91V8A/dVf/QVAf/UXAP3VX/0FIHF/d/RXfwEI729Pf/UXAP3VXwD0V3/1FwD9fTv9Hekv\
gP7qb3x/mx4rgP7qb139PWnoL4D+hv37Un/1F0B/9Vd/AdBf/dVfAP3VX/0FQH/1FwD91d+VjvQX\
gHJ9/X2Z/vb1FwD91V8A9Fd/9RdAf/VXfwHQX/3VXwD91V/9BUB/9RcA/dVf/QVAf/UXAP3VX/0F\
QH9r6O++/gKgv/oLgP7qr/4CoL/6C4D+6q/+AqC/+st//gXpCDcKWfH2cgAAAABJRU5ErkJggg=="

echo "$wallpaper" | base64 -d > "$wallpaperpath/GPV_Wallpaper.png"
echo "wallpaper created"

echo -e '\e[36m'"Settings display options: (desktop background, prevent screensaver, autostart of webbroswer at boot)"'\e[0m'
export DISPLAY=:0.0
pcmanfm --set-wallpaper "$wallpaperpath/GPV_Wallpaper.png"

# Prevent screensaver and open webpage at boot
echo '@xset s off' | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart
echo '@xset -dpms' | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart
echo '@xset s noblank' | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart
echo '/usr/bin/chromium-browser --kiosk --disable-restore-session-state https://inttargitapp.int.gpv.dk/anywhere' | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart

# Create disable HDMI service
echo "[Unit]" | sudo tee /etc/systemd/system/rpi_no_hdmi.service
echo "Description=Disable Raspberry Pi HDMI port" | sudo tee -a /etc/systemd/system/rpi_no_hdmi.service
echo "[Service]" | sudo tee -a /etc/systemd/system/rpi_no_hdmi.service
echo "Type=oneshot" | sudo tee -a /etc/systemd/system/rpi_no_hdmi.service
echo "ExecStart=/opt/vc/bin/tvservice -o" | sudo tee -a /etc/systemd/system/rpi_no_hdmi.service
echo "ExecStop=/opt/vc/bin/tvservice -p" | sudo tee -a /etc/systemd/system/rpi_no_hdmi.service
echo "RemainAfterExit=yes" | sudo tee -a /etc/systemd/system/rpi_no_hdmi.service
echo "[Install]" | sudo tee -a /etc/systemd/system/rpi_no_hdmi.service
echo "WantedBy=default.target" | sudo tee -a /etc/systemd/system/rpi_no_hdmi.service

# Add crontab entries
echo -e '\e[36m'"Adding crontab entries..."'\e[0m'
echo -e "$(sudo crontab -l 2>/dev/null)\n 45 5 * * 1,2,3,4,5 /sbin/shutdown -r now" | sudo crontab -
echo -e "$(sudo crontab -l 2>/dev/null)\n 10 22 * * 1,2,3,4,5 service rpi_no_hdmi start" | sudo crontab -
#(crontab -l 2>/dev/null; echo "0 8 * * 1,2,3,4,5 /sbin/shutdown -r now") | sudo crontab -
#(crontab -l 2>/dev/null; echo "0 20 * * 1,2,3,4,5 service rpi_no_hdmi start") | sudo crontab -
# adding to other user crontab:
# (crontab -l 2>/dev/null; echo "0 20 * * 1,2,3,4,5 service rpi_no_hdmi start") | sudo crontab -u pi -
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
