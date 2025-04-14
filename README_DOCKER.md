[![Learning Locker Logo](https://i.imgur.com/hP1yFKL.png)](http://learninglocker.net)

## How to start using docker

First, copy `docker_external.env` to `.env`.

```
cp docker_external.env .env
```

Edit the created `.env`. 
Set the protocol, SERVICE_HOST, time zone, etc. as required.

```
TZ=Asia/Tokyo
SERVICE_PROTOCOL=http
SERVICE_HOST=127.0.0.1.nip.io
SERVICE_DOMAIN=$SERVICE_PROTOCOL://$SERVICE_HOST
```

Then start the docker container.  
Access is possible on port 3000.

```
docker compose up -d --build
```

## Create an administrative user for Learning Locker

```
docker compose exec learninglocker node cli/dist/server createSiteAdmin {your email address} {your organization} {any password}
```

Example:

```
docker compose exec learninglocker node cli/dist/server createSiteAdmin admin@example.com demo 1Adminadmin
```
