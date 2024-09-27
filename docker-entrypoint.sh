#!/bin/bash

mongo_host=$(echo "$MONGODB_PATH" | awk -F[/:] '{print $4}')
query=$(cat <<EOS
rs.initiate({
  _id: "rs0",
  members: [
    {
      _id: 0,
      host: "${mongo_host}:27017",
    },
  ],
});
EOS
)

start(){

    while :
    do
      nc -v -w 1 "$mongo_host" 27017
      rc=$?
      if [ $rc -eq 0 ]
      then
        echo "mongod is up and running."
        break
      else
        echo "Waiting for mongod to start up..."
        sleep 3
      fi
    done

    echo -e "\n" $query | mongosh --host $mongo_host:27017

    cd /opt/learninglocker

    envsubst < /tmp/template.env > /opt/learninglocker/.env

    pm2 start --no-daemon /opt/learninglocker/pm2/all.json
}

case $1 in
    "start")
        start
    ;;
    "debug")
        /bin/sh -c "while :; do sleep 1; done"
    ;;
esac
