#/bin/bash

secrets=$(kubectl get secret -A | grep kubernetes.io/tls | grep home-tls | awk '{print $1";"$2}')

if [ $? != 0 ] || [ -z "$secrets" ]; then
	echo "Unable to list secrets !"
	exit 1
fi

crt=$(cat crt-new.base64)

if [ $? != 0 ] || [ -z "$crt" ]; then
	echo "Unable to load CRT encoded base64 file 'crt-new.base64' !"
	exit 1
fi

key=$(cat key-new.base64)

if [ $? != 0 ] || [ -z "$key" ]; then
	echo "Unable to load KEY encoded base64 file 'key-new.base64' !"
	exit 1
fi

for secret in $secrets
do
	sn=$(echo $secret | tr ';' '\t' | awk '{print $1}')
	name=$(echo $secret | tr ';' '\t' | awk '{print $2}')
	echo "> Patch secret : "$name" in "$sn
	kubectl patch secret $name -n $sn -p '{"data":{"tls.crt":"'$crt'"}}'
	kubectl patch secret $name -n $sn -p '{"data":{"tls.key":"'$key'"}}'
done
