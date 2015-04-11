#!/bin/bash
 
 ansible-playbook ./playbooks/esx/createKafkaCluster.yml  -i ./inventory/esxhosts -u root  --private-key=./keys/dockercloud-authkey --extra-vars "targethosts=50.248.177.195 vm_name=doche-repo-01"
