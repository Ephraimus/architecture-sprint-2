#!/bin/bash

docker-compose exec -T mongos mongosh --port 27020 <<EOF
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
EOF
