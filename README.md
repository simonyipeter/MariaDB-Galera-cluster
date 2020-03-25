# MariaDB-Galera-cluster
MariaDB Galera multi-master database cluster install script

# Install
- Setup the docker based on the offical description https://docs.docker.com/install/linux/docker-ce/ubuntu/
- Create a docker swarm as root, a minimum of 3 nodes is required, node1, node2, node3
```
#init the swarm:
root@node1:/# docker swarm init

#generate manager token and copy token to the node2 and node3
root@node1:/# docker swarm join-token manager
To add a manager to this swarm, run the following command:
   docker swarm join --token SWMTKN-1-0fo48mwadacjoz01iqnqnv9qiqkjh9ipzhct6ip2f63pagrk5o-36ybigvk9mkfoag1ph266o4x4 192.168.0.1:2377

#Join the node2 and node3 to the swarm
root@node1:/# docker swarm join --token SWMTKN-1-0fo48mwadacjoz01iqnqnv9qiqkjh9ipzhct6ip2f63pagrk5o-36ybigvk9mkfoag1ph266o4x4 192.168.0.1:2377

root@node2:/# docker swarm join --token SWMTKN-1-0fo48mwadacjoz01iqnqnv9qiqkjh9ipzhct6ip2f63pagrk5o-36ybigvk9mkfoag1ph266o4x4 192.168.0.1:2377

#check the results:
root@node1:/# docker node ls
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
egl8tjxb8kcwlppolmnu43tj8 *   node1               Ready               Active              Reachable           19.03.8
gkyht0zioff010q3n7v5wpmke     node2               Ready               Active              Reachable           19.03.8
j56c5kig56714zbbbk0rbc7aj     node3               Ready               Active              Leader              19.03.8


```
- Download the Docker compose: https://docs.docker.com/compose/install/
```
curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
```
- 
