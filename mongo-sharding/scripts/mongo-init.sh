#!/bin/bash

# Инициализация репликационного набора конфигурационных серверов
echo "Инициализация репликационного набора конфигурационных серверов"
docker-compose exec configsvr mongosh --port 27017 --eval 'rs.initiate({_id: "configReplSet", configsvr: true, members: [{ _id : 0, host : "configsvr:27017" }]})'

# Инициализация репликационного набора для шардов
echo "Инициализация репликационного набора для шардов"

docker-compose exec shard1 mongosh --port 27018 --eval 'rs.initiate({_id: "shard1ReplSet", members: [{ _id : 0, host : "shard1:27018" }]})'
docker-compose exec shard2 mongosh --port 27019 --eval 'rs.initiate({_id: "shard2ReplSet", members: [{ _id : 0, host : "shard2:27019" }]})'

# Добавление шардов в кластер
echo "Добавление шардов в кластер"
docker-compose exec mongos mongosh --port 27020 --eval 'sh.addShard("shard1ReplSet/shard1:27018")'
docker-compose exec mongos mongosh --port 27020 --eval 'sh.addShard("shard2ReplSet/shard2:27019")'

# Включение шардирования для базы данных и коллекции
echo "Включение шардирования для базы данных и коллекции"
docker-compose exec mongos mongosh --port 27020 --eval 'sh.enableSharding("somedb")'
docker-compose exec mongos mongosh --port 27020 --eval 'sh.shardCollection("somedb.helloDoc", {age: 1})'
docker-compose exec mongos mongosh --port 27020 --eval 'sh.shardCollection("somedb.helloDoc", {_id: "hashed"})'
