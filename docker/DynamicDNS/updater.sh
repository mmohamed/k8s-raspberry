#!/bin/sh

if [ -z "${USERNAME}" ]; then
  echo "Username needed !"
  exit 1
fi

if [ -z "${PASSWORD}" ]; then
  echo "Password needed !"
  exit 1
fi

if [ -z "${HOSTNAME}" ]; then
  echo "Hostname needed !"
  exit 1
fi

IP=$( dig +short myip.opendns.com @resolver1.opendns.com )

ACUTALIP=$( dig +short ${HOSTNAME} | tail -1 )

echo "Resolved IP ${IP} - ActualIP ${ACUTALIP}"

if [ "${IP}" != "${ACUTALIP}" ]; then
  URL="https://${USERNAME}:${PASSWORD}@domains.google.com/nic/update?hostname=${HOSTNAME}&myip=${IP}"
  curl -s "${URL}"
else
  echo "IP not changed !"
fi

exit 0
