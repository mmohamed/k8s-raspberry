#!/bin/bash
# nohup sh agent.sh [NODE-NAME] [YOUR-SECURITY-TOKEN] > /tmp/agent.log
if [ -z "$1" ]; then
	echo "Node name required !"
	exit 1
fi

if [ -z "$2" ]; then
	echo "Security Token required !"
	exit 1
fi

attempts=0
server="http[s]://[YOUR-API-BACKEN-URL]/k8s/collect/$1/temperature"

while true; do
	
	temperature=$(cat /sys/class/thermal/thermal_zone0/temp)
	
	if [ $? != 0 ] || [ -z "$temperature" ]; then
		echo "Unable to determinate CPU temperature value !"
		exit 1
	fi

	url="$server?node=$2&value=$temperature"
	
	responseCode=$(curl --silent --output /dev/null --write-out "%{http_code}" $url)
	
	if [ $? != 0 ] || [ -z "$responseCode" ] || [ $responseCode -ne 200 ]; then
		attempts=$((attempts + 1))
		echo "[ATTEMP-$attempts] Failed sending data to server : $responseCode"
		if [ $attempts = 20 ]; then
			echo "Server response error after 20 attempts !"
			exit 1
		fi;
	else
		attempts=0	
	fi

	sleep 5
done;