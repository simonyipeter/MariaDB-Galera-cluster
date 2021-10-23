GALERA_NODE_NAME=mariadb-galera
GALERA_DATA_ROOT_FOLDER=`pwd`/db_data
GALERA_DB=wordpress
GALERA_PWD=vAqC7wdtjRcsdDG

case $1 in
        bootstrap)
mkdir -p $GALERA_DATA_ROOT_FOLDER/data && mkdir -p $GALERA_DATA_ROOT_FOLDER/conf && chmod 777 -R $GALERA_DATA_ROOT_FOLDER/data && touch $GALERA_DATA_ROOT_FOLDER/conf/my.cnf
docker network create -d overlay --attachable pxc-network
docker run -d --name $GALERA_NODE_NAME-0 --net=pxc-network \
  -e MARIADB_GALERA_CLUSTER_BOOTSTRAP=yes \
  -e MARIADB_GALERA_CLUSTER_NAME=galera_cluster \
  -e MARIADB_GALERA_MARIABACKUP_USER=dbbck_user \
  -e MARIADB_GALERA_MARIABACKUP_PASSWORD=$GALERA_PWD \
  -e MARIADB_ROOT_PASSWORD=$GALERA_PWD \
  -e MARIADB_USER=$GALERA_DB \
  -e MARIADB_PASSWORD=$GALERA_PWD \
  -e MARIADB_DATABASE=$GALERA_DB \
  -p 3306:3306 \
  -p 4444:4444 \
  -p 4567:4567 \
  -p 4568:4568 \
  -v $GALERA_DATA_ROOT_FOLDER/data:/bitnami/mariadb \
  -v $GALERA_DATA_ROOT_FOLDER/conf/my.cnf:/opt/bitnami/mariadb/conf/bitnami/my_custom.cnf:ro \
  bitnami/mariadb-galera:latest
;;

start)
mkdir -p $GALERA_DATA_ROOT_FOLDER/data && mkdir -p $GALERA_DATA_ROOT_FOLDER/conf && chmod 777 -R $GALERA_DATA_ROOT_FOLDER/data && touch $GALERA_DATA_ROOT_FOLDER/conf/my.cnf
docker run -d --name $GALERA_NODE_NAME-$2 --net=pxc-network \
  -e MARIADB_GALERA_CLUSTER_NAME=galera_cluster \
  -e MARIADB_GALERA_CLUSTER_ADDRESS="gcomm://$GALERA_NODE_NAME-$3" \
  -e MARIADB_GALERA_MARIABACKUP_USER=dbbck_user \
  -e MARIADB_GALERA_MARIABACKUP_PASSWORD=$GALERA_PWD \
  -e MARIADB_ROOT_PASSWORD=$GALERA_PWD \
  -e MARIADB_USER=$GALERA_DB \
  -e MARIADB_PASSWORD=$GALERA_PWD \
  -e MARIADB_DATABASE=$GALERA_DB \
  -p 3306:3306 \
  -p 4444:4444 \
  -p 4567:4567 \
  -p 4568:4568 \
  -v $GALERA_DATA_ROOT_FOLDER/data:/bitnami/mariadb \
  -v $GALERA_DATA_ROOT_FOLDER/conf/my.cnf:/opt/bitnami/mariadb/conf/bitnami/my_custom.cnf:ro \
  --restart unless-stopped \
  bitnami/mariadb-galera:latest
;;


stop)
docker stop $(docker ps -a -f name=$GALERA_NODE_NAME* -q)
docker rm $(docker ps -a -f name=$GALERA_NODE_NAME* -q)
;;

status)
docker ps -a | grep -i $(docker ps -f name=$GALERA_NODE_NAME* -q)
docker exec -it $(docker ps -f name=$GALERA_NODE_NAME* -q) mysql -uroot -p$GALERA_PWD \
-e"SELECT * FROM information_schema.global_status WHERE variable_name IN ('WSREP_CLUSTER_STATUS','WSREP_LOCAL_STATE_COMMENT','WSREP_CLUSTER_SIZE','WSREP_EVS_DELAYED','WSREP_READY');"
;;

esac

