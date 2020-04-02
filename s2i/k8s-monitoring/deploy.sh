#!/bin/bash

if [ -z "$CRT" ] || [ -z "$KEY" ]; then
	echo "TLS CRT/KEY environment value not found !"
	exit 1
fi

if [ -z "$TOKEN" ]; then
	echo "Kube Token environment value not found !"
	exit 1
fi

if [ -z "$COLLECTORTOKEN" ]; then
	echo "Collector Token environment value not found !"
	exit 1
fi

echo "Get Kubectl"
curl -s -LO https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/linux/arm/kubectl
chmod +x ./kubectl

commitID=$(git log -1 --pretty="%H")

if [ $? != 0 ] || [ -z "$commitID" ]; then
	echo "Unable to determinate CommitID !"
	exit 1
fi

echo "Deploy for CommitID : ${commitID}"

# create new deploy
sed -i "s|{{crt}}|`echo $CRT`|g" api.yaml
sed -i "s|{{key}}|`echo $KEY`|g" api.yaml
sed -i "s|{{token}}|`echo $COLLECTORTOKEN`|g" api.yaml
sed -i "s|{{encodedtoken}}|`echo -ne $COLLECTORTOKEN | base64`|g" api.yaml
sed -i "s|{{host}}|api-monitoring.medinvention.dev|g" api.yaml
sed -i "s|{{commit}}|`echo $commitID`|g" api.yaml

./kubectl --token=$TOKEN apply -f api.yaml
if [ $? != 0 ]; then
	echo "Unable to deploy API !"
	exit 1
fi	

# wait for ready
attempts=0
rolloutStatusCmd="./kubectl --token=$TOKEN rollout status deployment/api -n monitoring"
until $rolloutStatusCmd || [ $attempts -eq 60 ]; do
  $rolloutStatusCmd
  attempts=$((attempts + 1))
  sleep 10
done

# create new deploy
sed -i "s|{{crt}}|`echo $CRT`|g" front.yaml
sed -i "s|{{key}}|`echo $KEY`|g" front.yaml
sed -i "s|{{host}}|monitoring.medinvention.dev|g" front.yaml
sed -i "s|{{commit}}|`echo $commitID`|g" front.yaml

./kubectl --token=$TOKEN apply -f front.yaml
if [ $? != 0 ]; then
	echo "Unable to deploy Front !"
	exit 1
fi	

# wait for ready
attempts=0
rolloutStatusCmd="./kubectl --token=$TOKEN rollout status deployment/front -n monitoring"
until $rolloutStatusCmd || [ $attempts -eq 60 ]; do
  $rolloutStatusCmd
  attempts=$((attempts + 1))
  sleep 10
done