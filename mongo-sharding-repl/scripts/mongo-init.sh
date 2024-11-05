#!/bin/bash

# Инициализация репликационного набора конфигурационных серверов
echo "Инициализация репликационного набора конфигурационных серверов"
docker-compose exec configsvr mongosh --port 27017 --eval 'rs.initiate({_id: "configReplSet", configsvr: true, members: [{ _id : 0, host : "configsvr:27017" }]})'

# Инициализация репликационного набора для шардов
echo "Инициализация репликационного набора для шардов"
docker-compose exec shard1-1 mongosh --port 27018 --eval 'rs.initiate({_id: "shard1ReplSet", members: [{ _id : 0, host : "shard1-1:27018" },{ _id : 1, host : "shard1-2:27028" },{ _id : 2, host : "shard1-3:27038" }]})'
docker-compose exec shard2-1 mongosh --port 27019 --eval 'rs.initiate({_id: "shard2ReplSet", members: [{ _id : 0, host : "shard2-1:27019" },{ _id : 1, host : "shard2-2:27029" },{ _id : 2, host : "shard2-3:27039" }]})'

#Если быстрее - то не успевает собраться кластер
sleep 15

# Добавление шардов в кластер
echo "Добавление шардов в кластер"
docker-compose exec mongos mongosh --port 27020 --eval 'sh.addShard("shard1ReplSet/shard1-1:27018")'
docker-compose exec mongos mongosh --port 27020 --eval 'sh.addShard("shard1ReplSet/shard1-2:27028")'
docker-compose exec mongos mongosh --port 27020 --eval 'sh.addShard("shard1ReplSet/shard1-3:27038")'

docker-compose exec mongos mongosh --port 27020 --eval 'sh.addShard("shard2ReplSet/shard2-1:27019")'
docker-compose exec mongos mongosh --port 27020 --eval 'sh.addShard("shard2ReplSet/shard2-2:27029")'
docker-compose exec mongos mongosh --port 27020 --eval 'sh.addShard("shard2ReplSet/shard2-3:27039")'

sleep 5

# Включение шардирования для базы данных и коллекции
echo "Включение шардирования для базы данных и коллекции"
docker-compose exec mongos mongosh --port 27020 --eval 'sh.enableSharding("somedb")'
docker-compose exec mongos mongosh --port 27020 --eval 'sh.shardCollection("somedb.helloDoc", {_id: "hashed"})'
