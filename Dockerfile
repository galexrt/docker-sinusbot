FROM ubuntu:xenial

LABEL maintainer="Alexander Trost <galexrt@googlemail.com>"

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8 " \
    SINUS_USER="3000" \
    SINUS_GROUP="3000" \
    SINUS_DIR="/sinusbot" \
    YTDL_BIN="/usr/local/bin/youtube-dl" \
    YTDL_VERSION="latest" \
    TS3_VERSION="3.2.3" \
    TS3_DL_ADDRESS="http://dl.4players.de/ts/releases/" \
    SINUSBOT_DL_URL="https://www.sinusbot.com/dl/sinusbot.current.tar.bz2"
    # That currently points to the latest beta version of Sinusbot

ENV SINUS_DATA="$SINUS_DIR/data" \
    SINUS_DATA_SCRIPTS="$SINUS_DIR/scripts" \
    SINUS_CONFIG="$SINUS_DIR/config" \
    TS3_DIR="$SINUS_DIR/TeamSpeak3-Client-linux_amd64"

RUN groupadd -g "$SINUS_GROUP" sinusbot && \
    useradd -u "$SINUS_USER" -g "$SINUS_GROUP" -d "$SINUS_DIR" sinusbot && \
    apt-get -q update -y && \
    apt-get -q upgrade -y && \
    apt-get -q install -y x11vnc xvfb libxcursor1 ca-certificates bzip2 libnss3 libegl1-mesa x11-xkb-utils libasound2 \
        libglib2.0-0 libnss3 locales wget sudo python less && \
    locale-gen --purge "$LANG" && \
    update-locale LANG="$LANG" && \
    echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale && \
    echo "LANG=en_US.UTF-8" >> /etc/default/locale && \
    update-ca-certificates && \
    mkdir -p "$SINUS_DIR" && \
    wget -qO- "$SINUSBOT_DL_URL" | \
    tar -xjf- -C "$SINUS_DIR" && \
    mv "$SINUS_DATA_SCRIPTS" "$SINUS_DATA_SCRIPTS-orig" && \
    mkdir -p "$SINUS_CONFIG" "$SINUS_DATA_SCRIPTS" && \
    cp -f "$SINUS_DIR/config.ini.dist" "$SINUS_DIR/config.ini" && \
    sed -i 's|^DataDir.*|DataDir = '"$SINUS_DATA"'|g' "$SINUS_DIR/config.ini" && \
    mkdir -p "$TS3_DIR" && \
    cd "$SINUS_DIR" || exit 1 && \
    wget -q -O "TeamSpeak3-Client-linux_amd64-$TS3_VERSION.run" \
        "$TS3_DL_ADDRESS/$TS3_VERSION/TeamSpeak3-Client-linux_amd64-$TS3_VERSION.run" && \
    chmod 755 "TeamSpeak3-Client-linux_amd64-$TS3_VERSION.run" && \
    yes | "./TeamSpeak3-Client-linux_amd64-$TS3_VERSION.run" && \
    rm -f "TeamSpeak3-Client-linux_amd64-$TS3_VERSION.run" && \
    rm TeamSpeak3-Client-linux_amd64/xcbglintegrations/libqxcb-glx-integration.so && \
    mkdir -p TeamSpeak3-Client-linux_amd64/plugins && \
    cp -f "$SINUS_DIR/plugin/libsoundbot_plugin.so" "$TS3_DIR/plugins/" && \
    sed -i "s|^TS3Path.*|TS3Path = \"$TS3_DIR/ts3client_linux_amd64\"|g" "$SINUS_DIR/config.ini" && \
    wget -q -O "$YTDL_BIN" "https://yt-dl.org/downloads/$YTDL_VERSION/youtube-dl" && \
    chmod a+rx "$YTDL_BIN" && \
    "$YTDL_BIN" -U && \
    echo "YoutubeDLPath = \"$YTDL_BIN-speedpatched\"" >> "$SINUS_DIR/config.ini" && \
    chown -fR sinusbot:sinusbot "$SINUS_DIR" && \
    apt-get -q clean all && \
    rm -rf /tmp/* /var/tmp/*

COPY entrypoint.sh /entrypoint.sh
COPY youtube-dl-speedpatched /usr/local/bin/youtube-dl-speedpatched

USER sinusbot
WORKDIR "$SINUS_DIR"

VOLUME ["$SINUS_DATA", "$SINUS_DATA_SCRIPTS", "$SINUS_CONFIG"]

EXPOSE 8087

ENTRYPOINT ["/entrypoint.sh"]
