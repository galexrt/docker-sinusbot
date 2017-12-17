# docker-sinusbot

[![](https://images.microbadger.com/badges/image/galexrt/sinusbot.svg)](https://microbadger.com/images/galexrt/sinusbot "Get your own image badge on microbadger.com")

[![Docker Repository on Quay.io](https://quay.io/repository/galexrt/sinusbot/status "Docker Repository on Quay.io")](https://quay.io/repository/galexrt/sinusbot)

Image available from:
* [**Quay.io**](https://quay.io/repository/galexrt/sinusbot)
* [**Docker Hub**](https://hub.docker.com/r/galexrt/sinusbot)

Docker Image with Sinusbot by Michael Friese.
TeamSpeak 3 SinusBot Homepage: https://sinusbot.com/.

Current version:
```
Sinusbot: latest beta (>=0.9.16-10f0fad)
TeamSpeak: 3.0.18.2 (this version is required for Sinusbot)
```

## Summary
* Debian Jessie with the latest version of Sinusbot
* You can inject your data into the container
  * /data

## Usage
### Updating the image
Run the below command, to update the image to the latest version:
```
docker pull quay.io/galexrt/sinusbot:latest
```

### Permissions
The default UID of the user which is used in the container is 3000.
So if you mount a directory from your host you have to set the permission to the user with the UID of 3000.
```
useradd -u 3000 sinusbot
mkdir -p /opt/docker/sinusbot/data /opt/docker/sinusbot/scripts
chown -R sinusbot:sinusbot /opt/docker/sinusbot/data /opt/docker/sinusbot/scripts
```
Or if you dont want to create an user just use
```
mkdir -p /opt/docker/sinusbot/data /opt/docker/sinusbot/scripts
chown -R 3000:3000 /opt/docker/sinusbot
```
Or just use the built-in variables to the run command to change the user and/or group id to an existing or non existing user:
The variables need to be an user/group id not the username:
```
SINUS_USER=3000
SINUS_GROUP=3000
```

### Mount host directory
```
docker run \
    --name sinusbot \
    -d \
    -v /opt/docker/sinusbot/data:/sinusbot/data \
    -v /opt/docker/sinusbot/scripts:/sinusbot/scripts \
    -p 8087:8087 \
    galexrt/sinusbot:latest
```

### SELinux
If your host uses SELinux it may be necessary to use the **:z** option:
```
docker run \
    --name sinusbot \
    -d \
    -v /opt/docker/sinusbot/data:/sinusbot/data:z \
    -v /opt/docker/sinusbot/scripts:/sinusbot/scripts:z \
    -p 8087:8087 \
    galexrt/sinusbot:latest
```

### Getting Sinusbot image
#### Normal
Replace `CONTAINER_NAME` with the container name or ID of the Sinusbot container and check the output for the password of Sinusbot (The password will only be shown on the first run of Sinusbot).
```
docker logs CONTAINER_NAME
```

#### With `LOGPATH` set
Replace `CONTAINER_NAME` with the container name or ID and `LOGPATH` with set value, in the following command:
```
docker exec CONTAINER_NAME cat LOGPATH
```

### Extra info
* Shell access while the container is running: `docker exec -it sinusbot /bin/bash`
* To monitor the logs in realtime or if you need to grab your sinusbot password: `docker logs -f sinusbot`
* Upgrade Youtube-dl to the latest version: `docker restart sinusbot` or via shell access `youtube-dl -U` (Normally not needed! A restart of the container updates `youtube-dl` too)
