# Ansible with Raspberry


##### 1- Set Ansible Inventary :
```
sed "s/{{masterip}}/[MASTERIP]/" hosts.dist > hosts 
sed -i "s/{{northip}}/[NORTHIP]/" hosts 
sed -i "s/{{southip}}/[SOUTHIP]/"  hosts 
sed -i "s/{{eastip}}/[eastip]/" hosts 
sed -i "s/{{westip}}/[westip]/"  hosts 

sed "s/{{user}}/[USER]/" group_vars/all.yml.dist > group_vars/all.yml
sed -i "s/{{password}}/[PASS]/" group_vars/all.yml
```

##### 2- Run Ansible :
* Run on all :
```
ansible-playbook bootstrap.yml -i hosts --verbose
```
* Run on master :
```
ansible-playbook master.yml -i hosts --verbose
```
* Run on node :
```
ansible-playbook node.yml -i hosts --verbose
```

##### 3- Manual Node Up :
```
sudo apt-get update -q
sudo apt install -qy apt-transport-https gnupg software-properties-common nfs-common
sudo wget -qO - https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list 
sudo apt-get update -q
sudo apt-get install -qy kubeadm
```