Kubernetes On Raspberry
=======================

#### 1-Get Hypriotos image [See](https://github.com/hypriot/image-builder-rpi/releases)
```
curl -Ss https://github.com/hypriot/image-builder-rpi/releases/download/v1.12.0/hypriotos-rpi-v1.12.0.img.zip
unzip hypriotos-rpi-v1.12.0.img.zip
```

#### 2-Install Hypriotos Flash Tool [See](https://github.com/hypriot/flash)
```
curl -LO https://github.com/hypriot/flash/releases/download/2.5.0/flash
chmod +x flash
sudo mv flash /usr/local/bin/flash
```

#### 3-Flush Master & Nodes
```
flash --hostname master hypriotos-rpi-v1.12.0.img
flash --hostname north hypriotos-rpi-v1.12.0.img
flash --hostname south hypriotos-rpi-v1.12.0.img
```

#### [4-Ansible for deployment](ansible/README.md)

#### [5-Set up cluster](kube/README.md)


#### 6-Get SSL for your domains (letsencrypt)[https://letsencrypt.org]


#### 7-Cluster Dashboard [See](https://blog.hypriot.com/post/setup-kubernetes-raspberry-pi-cluster/)
```
CRT=$(cat front/tls/cert | base64)
KEY=$(cat front/tls/key | base64)
sed  "s/{{crt}}/`echo $CRT`/" front/dashboard-deployment.yaml.dist | sed "s/{{key}}/`echo $KEY`/" | sed "s/{{host}}/[YOUR-HOSTNAME]/" > front/dashboard.yaml
kubectl apply -f front/dashboard.yaml
kubectl -n kube-system describe secret `kubectl -n kube-system get secret | grep replicaset-controller-token | awk '{print $1}'` | grep token: | awk '{print $2}'
```

#### 7-Deployment example (Using Docker Hub for image repository)
```
CRT=$(cat front/tls/cert | base64)
KEY=$(cat front/tls/key | base64)
sed  "s/{{crt}}/`echo $CRT`/" front/front-deployment.yaml.dist | sed "s/{{key}}/`echo $KEY`/" | sed "s/{{host}}/[YOUR-HOSTNAME]/" | sed "s/{{name}}/[YOUR-APPNAME]/" | sed "s/{{image}}/[YOUR-IMGPATH]/" > front/deployment.yaml
kubectl apply -f front/deployment.yaml
```