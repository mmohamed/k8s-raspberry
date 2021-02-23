# AMR64 with Ubuntu on Worker (RPI4)

## [1-Install Ubuntu Server on SD Card](https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#1-overview)

<img src="https://ubuntucommunity.s3.dualstack.us-east-2.amazonaws.com/original/2X/8/863a5a956284964af095103ebddc75a4f922c15e.jpeg" width="900">

## [2-Prepare Host (create your user and delete generic ubuntu user)](https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#4-boot-ubuntu-server)
```
sudo echo -n 'cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1' >> /boot/firmware/cmdline.txt
sudo hostnamectl set-hostname [NODE-HOSTNAME]
sudo adduser [USER]
sudo usermod -aG sudo [USER]
sudo usermod -aG docker [USER]
sudo userdel ubuntu
sudo rm -r /home/ubuntu
```

## [3-Install Docker & Kube](https://phoenixnap.com/kb/install-kubernetes-on-ubuntu)
```
sudo apt-get update
sudo apt-get install docker.io
sudo systemctl enable docker
sudo systemctl status docker
sudo systemctl start docker
```

```
sudo apt-get update -q
sudo apt install -qy apt-transport-https gnupg software-properties-common nfs-common
sudo wget -qO - https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list 
sudo apt-get update -q
sudo apt-get install -qy kubeadm=1.17.1-00 kubelet=1.18.5-00 
sudo apt-mark hold kubeadm kubelet 
```

## [4-Up Worker](https://phoenixnap.com/kb/install-kubernetes-on-ubuntu)
```
kubeadm token create --print-join-command
```

```
kubeadm join --discovery-token abcdef.1234567890abcdef --discovery-token-ca-cert-hash sha256:1234..cdef 1.2.3.4:6443
```