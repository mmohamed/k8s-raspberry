Setup cluster
=======================

#### 1-Install Flannel for CNI 
```
kubectl create -f kube/flannel.yml
kubectl create -f kube/kubedns.yml
# Must be done on all node
sudo sysctl net.bridge.bridge-nf-call-iptables=1
```

#### 2-Install Nginx Ingress
```
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm install nginx-ingress stable/nginx-ingress --set defaultBackend.image.repository=docker.io/medinvention/ingress-default-backend,controller.image.repository=quay.io/kubernetes-ingress-controller/nginx-ingress-controller-arm,defaultBackend.image.tag=latest,controller.image.tag=0.27.1
helm install ingress stable/nginx-ingress --set controller.hostNetwork=true,controller.kind=DaemonSet
# Check public IP if set
kubectl get svc ingress-nginx-ingress-controller -o jsonpath="{.status.loadBalancer.ingress[0].ip}"
# You can set it manual
kubectl patch svc nginx-ingress-controller -p '{"spec": {"type": "LoadBalancer", "externalIPs":["[YOUR-PUBLIC-IP]"]}}'
# If Pod cannot communicate, run in all node 
sudo systemctl stop docker
sudo iptables -t nat -F
sudo iptables -P FORWARD ACCEPT
sudo ip link del docker0
sudo ip link del flannel.1
sudo systemctl start docker
```

#### 3- Install NFS Storage (With testing)
```
kubectl apply -f storage/nfs-deployment.yml
kubectl apply -f storage/nfs-testing.yml
```

#### 4- Cluster Tear down :
```
kubeadm reset
```