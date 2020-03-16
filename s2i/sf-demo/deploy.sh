#!/bin/bash

if [ -z "$CRT" ] || [ -z "$KEY" ]; then
	echo "TLS CRT/KEY environment value not found !"
	exit 1
fi

if [ -z "$TOKEN" ]; then
	echo "Kube Token environment value not found !"
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

bddep=$(./kubectl --token=$TOKEN get deployment mysql -n sfdemo)
if [ $? != 0 ]; then
	# create new deploy
	./kubectl --token=$TOKEN apply -f mysql.yaml
	if [ $? != 0 ]; then
		echo "Unable to deploy database !"
		exit 1
	fi
fi

# wait for ready
attempts=0
rolloutStatusCmd="./kubectl --token=$TOKEN rollout status deployment/mysql -n sfdemo"
until $rolloutStatusCmd || [ $attempts -eq 60 ]; do
  $rolloutStatusCmd
  attempts=$((attempts + 1))
  sleep 10
done



memdep=$(./kubectl --token=$TOKEN get deployment memcached -n sfdemo)
if [ $? != 0 ]; then
	# create new deploy
	./kubectl --token=$TOKEN apply -f memcached.yaml
	if [ $? != 0 ]; then
		echo "Unable to deploy memcached server !"
		exit 1
	fi
fi

# wait for ready
attempts=0
rolloutStatusCmd="./kubectl --token=$TOKEN rollout status deployment/memcached -n sfdemo"
until $rolloutStatusCmd || [ $attempts -eq 60 ]; do
  $rolloutStatusCmd
  attempts=$((attempts + 1))
  sleep 10
done


appdep=$(./kubectl --token=$TOKEN get deployment app -n sfdemo)
if [ $? != 0 ]; then
	# create new deploy
	sed -i "s|{{crt}}|`echo $CRT`|g" app.yaml
	sed -i "s|{{key}}|`echo $KEY`|g" app.yaml
	sed -i "s|{{host}}|sfdemo.medinvention.dev|g" app.yaml
	sed -i "s|{{commit}}|`echo $commitID`|g" app.yaml

	./kubectl --token=$TOKEN apply -f app.yaml
	if [ $? != 0 ]; then
		echo "Unable to deploy application !"
		exit 1
	fi	
else
	# patch it
	./kubectl --token=$TOKEN patch deployment app -n sfdemo -p '{"spec":{"template":{"metadata":{"labels":{"commit":"'$commitID'"}}}}}'
	if [ $? != 0 ]; then
		echo "Unable to patch application deploy !"
		exit 1
	fi	
fi

# wait for ready
attempts=0
rolloutStatusCmd="./kubectl --token=$TOKEN rollout status deployment/app -n sfdemo"
until $rolloutStatusCmd || [ $attempts -eq 60 ]; do
  $rolloutStatusCmd
  attempts=$((attempts + 1))
  sleep 10
done