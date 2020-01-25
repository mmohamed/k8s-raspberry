Kubernetes On Raspberry
=======================

#### Set Ansible Inventary :
```
sed "s/{{masterip}}/[MASTERIP]/" ansible/hosts.dist | sed "s/{{northip}}/[NORTHIP]/" | sed "s/{{southip}}/[SOUTHIP]/" > ansible/hosts
sed "s/{{user}}/[USER]/" ansible/group_vars/all.yml.dist | sed "s/{{password}}/[PASS]/" > ansible/group_vars/all.yml
```

#### Run Ansible :
- Run on all :
```
ansible-playbook bootstrap.yml -i hosts --verbose
```
- Run on master :
```
ansible-playbook master.yml -i hosts --verbose
```
- Run on node :
```
ansible-playbook node.yml -i hosts --verbose
```