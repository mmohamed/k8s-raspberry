# Kubernetes On Raspberry

How to deploy a Kubernetes K8S solution on your own cluster composed by some raspberry

<img src="https://github.com/mmohamed/k8s-raspberry/blob/master/cover.jpg" width="900" height="900">

----

##### [1- Get Hypriotos image](https://github.com/hypriot/image-builder-rpi/releases)
```
curl -OJSLs https://github.com/hypriot/image-builder-rpi/releases/download/v1.12.0/hypriotos-rpi-v1.12.0.img.zip
unzip hypriotos-rpi-v1.12.0.img.zip
```

##### [2-Install Hypriotos Flash Tool & flush all nodes](https://github.com/hypriot/flash)
```
curl -LO https://github.com/hypriot/flash/releases/download/2.5.0/flash
chmod +x flash && sudo mv flash /usr/local/bin/flash
flash --hostname [HOSTNAME] hypriotos-rpi-v1.12.0.img
```

##### [3-Ansible for deployment](ansible/README.md)

##### [4-Set up cluster](kube/README.md)

##### [5-Get SSL for your domains  from letsencrypt](https://letsencrypt.org)

##### [6-Cluster Dashboard](https://blog.hypriot.com/post/setup-kubernetes-raspberry-pi-cluster/)
```
# get SSL CRT & KEY base64 encoded & make deployment YAML
cp dashboard-deployment.yaml.dist dashboard.yaml
sed -i "s/{{crt}}/[YOUR-CRT]/" dashboard.yaml
sed -i "s/{{key}}/[YOUR-KEY]/"  dashboard.yaml
sed -i "s/{{host}}/[YOUR-HOSTNAME]/" dashboard.yaml
# deploy
kubectl apply -f dashboard.yaml
# get access token
kubectl -n kube-system describe secret `kubectl -n kube-system get secret | grep replicaset-controller-token | awk '{print $1}'` | grep token: | awk '{print $2}'
```

##### [7-Deployment example (Using Docker Hub for image repository)](https://hub.docker.com/u/medinvention)
```
# get SSL CRT & KEY base64 encoded & make deployment YAML
cp front-deployment.yaml.dist deployment.yaml
sed -i "s/{{key}}/[YOUR-KEY]/" deployment.yaml
sed -i "s/{{key}}/[YOUR-KEY]/" deployment.yaml
sed -i "s/{{host}}/[YOUR-HOSTNAME]/" deployment.yaml
sed -i "s/{{name}}/[YOUR-APPNAME]/" deployment.yaml
sed -i "s/{{image}}/[YOUR-IMGPATH]/" deployment.yaml
# deploy
kubectl apply -f deployment.yaml
```

---- 

[*More informations*](https://blog.medinvention.dev)