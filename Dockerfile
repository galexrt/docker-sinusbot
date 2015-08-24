FROM debian:jessie
MAINTAINER Alexander Trost <galexrt@googlemail.com>

ENV SINUS_VERSION="0.9.8" SINUS_USER="sinusbot" SINUS_GROUP="sinusbot" SINUS_DIR="/opt/sinusbot" SINUS_DATA="/data"
ENV TS3_VERSION="3.0.16" TS3_OFFSET="49134" TS3_DIR="$SINUS_DIR/TeamSpeak3-Client-linux_amd64"
ENV YTDL_VERSION="latest" YTDL_BIN="/usr/local/bin/youtube-dl"
ADD entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh && \
    apt-get update -q && \
    apt-get install -yq \
    locales \
    wget \
    x11vnc \
    xinit \
    xvfb \
    libxcursor1 \
    libglib2.0-0 \
    python \
    bzip2 \
    ca-certificates && \
    update-ca-certificates && \
    wget -qO "$YTDL_BIN" "https://yt-dl.org/downloads/$YTDL_VERSION/youtube-dl" && \
    chmod a+rx "$YTDL_BIN" && \
    locale-gen --purge en_US.UTF-8 && \
    echo LC_ALL=en_US.UTF-8 >> /etc/default/locale && \
    echo LANG=en_US.UTF-8 >> /etc/default/locale && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    groupadd -g 3000 -r "$SINUS_GROUP" && \
    useradd -u 3000 -r -g "$SINUS_GROUP" -d "$SINUS_DIR" "$SINUS_USER" && \
    mkdir -p "$SINUS_DIR" "$TS3_DIR" && \
    wget -qO- http://frie.se/ts3bot/sinusbot-$SINUS_VERSION.tar.bz2 | \
    tar -xjf- -C "$SINUS_DIR" && \
    wget -qO- "http://dl.4players.de/ts/releases/$TS3_VERSION/TeamSpeak3-Client-linux_amd64-$TS3_VERSION.run" | \
    tail -c +$TS3_OFFSET | \
    tar -xzf- -C "$TS3_DIR" && \
    mv "$SINUS_DIR/config.ini.dist" "$SINUS_DIR/config.ini" && \
    sed -i "s|TS3Path = .*|TS3Path = \"$TS3_DIR/ts3client_linux_amd64\"|g" "$SINUS_DIR/config.ini" && \
    echo YoutubeDLPath = \"$YTDL_BIN\" >> "$SINUS_DIR/config.ini" && \
    cp "$SINUS_DIR/plugin/libsoundbot_plugin.so" "$TS3_DIR/plugins/" && \
    chown "$SINUS_USER":"$SINUS_GROUP" -R "/entrypoint.sh" "$SINUS_DIR" "$TS3_DIR" && \
    ln -s "$SINUS_DIR/data" "$SINUS_DATA"
VOLUME "$SINUS_DIR"
EXPOSE 8087
ENTRYPOINT ["/entrypoint.sh"]
