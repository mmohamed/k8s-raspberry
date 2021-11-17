## Fresh install
```
curl -OJSLs https://github.com/hypriot/image-builder-rpi/releases/download/v1.12.0/hypriotos-rpi-v1.12.0.img.zip
unzip hypriotos-rpi-v1.12.0.img.zip
```
## Activate cgroup adn disabling Swap
```
sudo echo " cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" >> /boot/cmdline.txt
sudo swapoff -a
```

## Updating Hostname and password
```
sudo hostnamectl set-hostname master
edit  : /etc/hostname
		/etc/hosts		
add hosts to :
	/etc/cloud/templates/hosts.debian.tmpl
	/etc/hosts
sudo passwd	
sudo reboot
```

## Install kube
```
sudo apt-get update -q
sudo apt install -qy apt-transport-https gnupg software-properties-common nfs-common
sudo wget -qO - https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list 
sudo apt-get update -q
sudo apt-get install -qy kubeadm=1.17.1-00 kubelet=1.18.5-00 
sudo apt-mark hold kubeadm kubelet 
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
sudo mkdir /home/pirate/.kube
sudo chmod 0755 -R /home/pirate/.kube
sudo chown -r pirate:root /home/pirate/.kube
sudo cp /etc/kubernetes/admin.conf /home/pirate/.kube/config
kubeadm token create --print-join-command
```

## Install Flannel And Kube DNS
```
kubectl apply -f https://raw.githubusercontent.com/mmohamed/k8s-raspberry/master/kube/flannel.yml
curl -sSL https://raw.githubusercontent.com/mmohamed/k8s-raspberry/master/kube/kubedns.yaml | sed "s/amd64/arm/g" | kubectl create -f -
sudo sysctl net.bridge.bridge-nf-call-iptables=1
```

## Install HELM
```
curl -fsSL -o helm-v3.0.2-linux-arm.tar.gz https://get.helm.sh/helm-v3.0.2-linux-arm.tar.gz
tar -xvf helm-v3.0.2-linux-arm.tar.gz
sudo cp ./linux-arm/helm /usr/bin/helm
sudo helm init
```

## Install Ingress
```
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm install nginx-ingress stable/nginx-ingress --set defaultBackend.image.repository=docker.io/medinvention/ingress-default-backend,controller.image.repository=quay.io/kubernetes-ingress-controller/nginx-ingress-controller-arm,defaultBackend.image.tag=latest,controller.image.tag=0.27.1
helm install ingress stable/nginx-ingress --set controller.hostNetwork=true,controller.kind=DaemonSet
* Check public IP if set
kubectl get svc ingress-nginx-ingress-controller -o jsonpath="{.status.loadBalancer.ingress[0].ip}"
* You can set it manual
kubectl patch svc nginx-ingress-controller -p '{"spec": {"type": "LoadBalancer", "externalIPs":["[YOUR-PUBLIC-IP]"]}}'
```

## Install NFS
```
sudo systemctl enable nfs-kernel-server
sudo systemctl start nfs-kernel-server
sudo cat >> /etc/exports <<EOF
/data/kubernetes-storage/ north(rw,sync,no_subtree_check,no_root_squash)
/data/kubernetes-storage/ south(rw,sync,no_subtree_check,no_root_squash)
EOF
sudo exportfs -a 
kubectl apply -f https://raw.githubusercontent.com/mmohamed/k8s-raspberry/master/storage/nfs-deployment.yaml
kubectl apply -f https://raw.githubusercontent.com/mmohamed/k8s-raspberry/master/storage/nfs-testing.yaml
```
## Join
```
master => kubeadm token create --print-join-command
each nodes => kubeadm join --discovery-token abcdef.1234567890abcdef --discovery-token-ca-cert-hash sha256:1234..cdef 1.2.3.4:6443
```
