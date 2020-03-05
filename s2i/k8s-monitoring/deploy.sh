
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

apidep=$(./kubectl --token=$TOKEN get deployment api -n monitoring)
if [ $? != 0 ]; then
	# create new deploy
	sed -i "s|{{crt}}|`echo $CRT`|g" api.yaml
	sed -i "s|{{key}}|`echo $KEY`|g" api.yaml
	sed -i "s|{{host}}|api-monitoring.medinvention.dev|g" api.yaml
	sed -i "s|{{commit}}|`echo $commitID`|g" api.yaml

	./kubectl --token=$TOKEN apply -f api.yaml
	if [ $? != 0 ]; then
		echo "Unable to deploy API !"
		exit 1
	fi	
else
	# patch it
	./kubectl --token=$TOKEN patch deployment api -n monitoring -p '{"spec":{"template":{"metadata":{"labels":{"commit":"'$commitID'"}}}}}'
	if [ $? != 0 ]; then
		echo "Unable to patch API deployment !"
		exit 1
	fi	
fi

# wait for ready
attempts=0
rolloutStatusCmd="./kubectl --token=$TOKEN rollout status deployment/api -n monitoring"
until $rolloutStatusCmd || [ $attempts -eq 60 ]; do
  $rolloutStatusCmd
  attempts=$((attempts + 1))
  sleep 10
done

appdep=$(./kubectl --token=$TOKEN get deployment front -n monitoring)
if [ $? != 0 ]; then
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
else
	# patch it
	./kubectl --token=$TOKEN patch deployment front -n monitoring -p '{"spec":{"template":{"metadata":{"labels":{"commit":"'$commitID'"}}}}}'
	if [ $? != 0 ]; then
		echo "Unable to patch Front deployment !"
		exit 1
	fi	
fi

# wait for ready
attempts=0
rolloutStatusCmd="./kubectl --token=$TOKEN rollout status deployment/front -n monitoring"
until $rolloutStatusCmd || [ $attempts -eq 60 ]; do
  $rolloutStatusCmd
  attempts=$((attempts + 1))
  sleep 10
done