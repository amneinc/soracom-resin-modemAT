#!/bin/bash
# Setting DBUS addresss so that we can talk to Modem Manager
DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket

# Start Dropbear SSHD
if [[ -n "${SSH_PASSWD}" ]]; then
	#Set the root password
	echo "root:$SSH_PASSWD" | chpasswd
	#Spawn dropbear
	dropbear -E -F &
fi

# Check if we have a modem attached to device
# sleep 22 seconds to give Modem Manager enough time to configure GSM Modem
sleep 22
mmcli -L | grep -q Modem
if [ $? -eq 0 ]; then
	MODEM_NUMBER=`mmcli -L | grep Modem | sed -e 's/\//\ /g' | awk '{print $5}'`
fi

# Check if we should disable non-cellular connectivity
#if [[ ${CELLULAR_ONLY} == "1" ]]; then
#	ls /sys/class/net | grep -q wlan0
#	if [[ $? -eq 0 ]]; then
#		ifconfig wlan0 down
#	fi
#	ls /sys/class/net | grep -q eth0
#	if [[ $? -eq 0 ]]; then
#		ifconfig eth0 down
#	fi
#	if [[ -n "${MODEM_NUMBER}" ]]; then
#		# Check to see if Modem successfully connected
#		mmcli -m ${MODEM_NUMBER} | grep -q "state: 'connected'"
#		if [ $? -eq 0 ]; then
#			CONNECTED=1
#		fi
#	else
#		curl -s --connect-timeout 52 http://ifconfig.io
#		if [ $? -eq 0 ]; then
#			CONNECTED=1
#		fi
#	fi
#	if [[ -n "${CONNECTED}" ]]; then
#		echo "Device successfully connected over Cellular"
#	else
#		echo "Re-enabling Ethernet and WiFi as device didn't have internet without it"
#		ls /sys/class/net | grep -q eth0
#		if [[ $? -eq 0 ]]; then
#			ifconfig eth0 up
#		fi
#		ls /sys/class/net | grep -q wlan0
#		if [[ $? -eq 0 ]]; then
#			ifconfig wlan0 up
#		fi
#	fi
#fi
echo "App Started"

# Run connection check script every 15mins
# wait indefinitely
while :
do
	MODEM_NUMBER=`mmcli -L | grep Modem | sed -e 's/\//\ /g' | awk '{print $5}'`
	# Log signal quality
	if [[ -n "${MODEM_NUMBER}" ]]; then
		echo "`mmcli -m ${MODEM_NUMBER} | grep quality | sed -e \"s/'//g\" | awk '{print $2 " " $3 " " $4}'`%"
		echo `mmcli -m ${MODEM_NUMBER} --command="AT+CSQ"`
	fi
	sleep 300;
	#/usr/src/app/reconnect.sh
done