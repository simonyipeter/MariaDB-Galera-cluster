# MariaDB-Galera-cluster
MariaDB Galera multi-master database cluster install script

# Install
- Setup the docker based on the offical description https://docs.docker.com/install/linux/docker-ce/ubuntu/
- Create a docker swarm as root, a minimum of 3 nodes is required. (in this tutorial: node1, node2, node3 )

```
#init the swarm:
root@node1:/# docker swarm init

#generate manager token and copy the token to the node2 and node3
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

- Clone the reposity to each node.

```
#create a new folder
mkdir /cluster && cd /cluster
#download the reposity
curl -L "https://raw.githubusercontent.com/simonyipeter/MariaDB-Galera-cluster/master/wsrep_service.sh" -o wsrep_service.sh && chmod +x wsrep_service.sh
```

# Configuration
- Edit the wsrep_service.sh file with your best text editor:

```
mcedit wsrep_service.sh
```

- Modify the GALERA_DATA_ROOT_FOLDER variable, the cluster will store database files here. GALERA_DB will be the first database in the cluster and the password and the root password will be stored in the GALERA_PWD variable.

- Start the first container on any node, it will initial the cluster. the container name will mariadb-galera-0
Each container will use this ports: 3306/tcp 4444/tcp and 4567-4568/tcp, so before start container, stop the mysql server on the host or modify the port number in the wsrep_service.sh Example: -p 3306:3306 -> -p 3307:3306 

```
root@node1:/cluster# ./wsrep_service.sh bootstrap
```

- On the next node clone the reposity and join to the cluster, mariadb-galera-2 will be the container name which joint to the mariadb-galera-0

```
root@node2:/cluster# ./wsrep_service.sh start 2 0
# and the next node join to mariadb-galera-2
root@node3:/cluster# ./wsrep_service.sh start 3 2
```

- Check the cluster state on any node:

```
root@node2:/cluster# ./wsrep_service.sh status
+---------------------------+----------------+
| VARIABLE_NAME             | VARIABLE_VALUE |
+---------------------------+----------------+
| WSREP_CLUSTER_SIZE        | 3              |
| WSREP_CLUSTER_STATUS      | Primary        |
| WSREP_EVS_DELAYED         |                |
| WSREP_LOCAL_STATE_COMMENT | Synced         |
| WSREP_READY               | ON             |
+---------------------------+----------------+

```

- Let's destroy and the first container on node1 and create a new one:

```
root@node1:/cluster# ./wsrep_service.sh stop
root@node1:/cluster# ./wsrep_service.sh start 1 2
#After a few seconds, check again the status:
root@node1:/cluster# ./wsrep_service.sh status
```

# Backup
Easy to create backup from all database: 
```
root@node2:/cluster# ./wsrep_service.sh backup
```
The backup files wil located in the db_bkp folder
