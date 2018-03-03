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
Sinusbot: latest beta (>=0.11.0)
TeamSpeak: 3.1.8 (this version is required for Sinusbot)
```
For more info about the image, see [Image contents](#image-contents).

## Usage
### Quick Guide
By using this image you accept TeamSpeak's and Sinusbot's license agreements.

**IMPORTANT** You need data persistence to be able to update the Sinusbot container image without losing your data!

* To run the Sinusbot container with data persistence see: [Mount host directory](#mount-host-directory).
* To run the Sinusbot container without data persistence, see [Mount host directory](#mount-host-directory) but remove the `-v ...` flags.

When you have started the Sinusbot for the first time, you need to get the password from the logs, see [Get Sinusbot Password](#get-sinusbot-password).

**WARNING** There is "no way" to show the password a second time!

If you run into issues, please create an issue in this GitHub project with as much details of your issue as possible. Thanks!

### Mount host directory
This allows you to update the container image with new Sinusbot versions, without losing your data.

You need to run the following two commands before starting/running the container:
```
sudo mkdir -p /opt/docker/sinusbot/data /opt/docker/sinusbot/scripts /opt/docker/sinusbot/config
sudo chown 3000:3000 -R /opt/docker/sinusbot/data /opt/docker/sinusbot/scripts /opt/docker/sinusbot/config
```
(`sudo` can be removed if you are not using it or are logged in as `root`)

**IMPORTANT** When using Docker for Mac the files need to be owned by the user running the container. More information: https://docs.docker.com/docker-for-mac/osxfs/#ownership


To then start the Sinusbot container run:
```
docker run \
    --name sinusbot \
    -d \
    -v /opt/docker/sinusbot/data:/sinusbot/data \
    -v /opt/docker/sinusbot/scripts:/sinusbot/scripts \
    -v /opt/docker/sinusbot/config:/sinusbot/config \
    -p 8087:8087 \
    quay.io/galexrt/sinusbot:latest
```

### Get Sinusbot Password
Replace `CONTAINER_NAME` with the container name (`--name` flag in `docker run` command) or ID of the Sinusbot container and check the output for the password of Sinusbot (The password will only be shown on the first run of Sinusbot).
```
docker logs CONTAINER_NAME
```

The username and password are printed out like this:
```
[...]
-------------------------------------------------------------------------------
Generating new bot instance with account 'admin' and password 'YOUR_PASSWORD_HERE'
PLEASE MAKE SURE TO CHANGE THE PASSWORD DIRECTLY AFTER YOUR FIRST LOGIN!!!
-------------------------------------------------------------------------------
[...]
```

### Editing the config file
The config file is available in the container path `/sinusbot/config`.
The example above mounts the `/sinusbot/config` directory to `/opt/docker/sinusbot/config`.
After editing the `config.ini`, you need to restart the container for Sinusbot to pickup the changes.

### Updating the image
Run the below command, to update the container image to the latest version:
```
docker pull quay.io/galexrt/sinusbot:latest
```
After the pull of the latest container image, you have to restart your Sinusbot container.
An example on this can be done is:
```
docker restart CONTAINER_NAME
```
(Replace `CONTAINER_NAME` with the container name (`--name` flag in `docker run` command) or ID of the Sinusbot container)

### Get Sinusbot Container name
The Sinusbot container name is the value of the `--name` flag.
In the examples provided here, it is `sinusbot`.

### File Permissions
The default UID (and GID) which is used in the container is `3000`.
This is done because it is safer to run as a non root user (even in a container).

To change the UID (and GID), see [Change UID of Container](#changing-uid-of-container).

### SELinux
If your host uses SELinux it may be necessary to add the **:z** option to the volumes:
```
docker run \
[...]
    -v /opt/docker/sinusbot/data:/sinusbot/data:z \
    -v /opt/docker/sinusbot/scripts:/sinusbot/scripts:z \
    -v /opt/docker/sinusbot/config:/sinusbot/config:z \
[...]
```
This assumes that your data paths are located at the paths after the `-v` flag up to the `:`.

### Change UID of Container
Changing the UID of the user used in the container, can be done in two ways.
* Adding `--user USER_ID:GROUP_ID` to your `docker run` command (before the image name) and changing the host directory owner and group to the given ID.
* Rebuilding the image with to your needs changed `SINUS_USER` and `SINUS_GROUP` environment vars in the `Dockerfile`.

The variables need to be an user/group id not the username:
```
SINUS_USER=3000
SINUS_GROUP=3000
```

### Migrating from the "old" Container image
If your data is owned by `root` (UID `0`), you need to run:
```
chown 3000:3000 -R /opt/docker/sinusbot/data /opt/docker/sinusbot/scripts /opt/docker/sinusbot/config
```
This assumes that your data paths are currently located at the two paths behind the `-R` flag.
Don't forget to check if your `docker run` command is still uptodate with now two volumes, first (`.../data`) for data and the second (`.../scripts`) for Sinusbot scripts.
Also note that most flags that were previously available have been removed.

### Extra info
Replace `CONTAINER_NAME` with the container name (`--name` flag in `docker run` command) or ID of the Sinusbot container.
* Shell access while the container is running: `docker exec -it CONTAINER_NAME /bin/bash`.
* To follow the Sinusbot logs or if you need to grab your Sinusbot password on the first run, use: `docker logs -f CONTAINER_NAME`.
* Upgrade Youtube-dl to the latest version via shell access (see first point in this list) `youtube-dl -U`. You should normally just update the container image and restart it, see [Usage - Updating the image](#updating-the-image)).

## Image contents
* Ubuntu Xenial with the latest version of Sinusbot
* Volumes for Sinusbot data, scripts and config:
  * `/sinusbot/data`
  * `/sinusbot/scripts`
  * `/sinusbot/config`
* Sinusbot Port `8087`
* Youtube-DL
* TeamSpeak Client
