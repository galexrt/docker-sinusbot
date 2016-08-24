FROM debian:jessie

MAINTAINER Alexander Trost <galexrt@googlemail.com>

ENV SINUS_USER=3000 \
    SINUS_GROUP=3000 \
    SINUS_DIR="/sinusbot" \
    SINUS_DATA="$SINUS_DIR/data" \
    YTDL_BIN="/usr/local/bin/youtube-dl" \
    TS3_DIR="$SINUS_DIR/TeamSpeak3-Client-linux_amd64" \
    SINUS_VERSION="0.9.12.3-36fce3c" \
    YTDL_VERSION="latest" \
    TS3_VERSION="3.0.19.4" \
    TS3_OFFSET="25000"

ADD entrypoint.sh /entrypoint.sh

RUN groupadd -g "$SINUS_GROUP" sinusbot && \
    useradd -u "$SINUS_USER" -g "$SINUS_GROUP" -d "$SINUS_DIR" sinusbot && \
    apt-get -q update && \
    apt-get -q upgrade -y && \
    apt-get -q install -y libpulse0 locales wget sudo python bzip2 sqlite3 ca-certificates libglib2.0-0 x11vnc xvfb libxcursor1 xcb && \
    update-ca-certificates && \
    locale-gen --purge en_US.UTF-8 && \
    echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale && \
    echo "LANG=en_US.UTF-8" >> /etc/default/locale && \
    mkdir -p "$SINUS_DIR" "$TS3_DIR"

RUN wget -qO- "https://www.sinusbot.com/pre/sinusbot-$SINUS_VERSION.tar.bz2" | \
    tar -xjf- -C "$SINUS_DIR"

RUN wget -q -O- "http://dl.4players.de/ts/releases/$TS3_VERSION/TeamSpeak3-Client-linux_amd64-$TS3_VERSION.run" | \
    tail -c +$TS3_OFFSET | \
    tar xzf - -C "$TS3_DIR"

RUN wget -q -O "$YTDL_BIN" "https://yt-dl.org/downloads/$YTDL_VERSION/youtube-dl" && \
    chmod 755 -f "$YTDL_BIN"

RUN mv -f "$SINUS_DIR/config.ini.dist" "$SINUS_DIR/config.ini" && \
    sed -i "s|TS3Path = .*|TS3Path = \"$TS3_DIR/ts3client_linux_amd64\"|g" "$SINUS_DIR/config.ini" && \
    echo "YoutubeDLPath = \"$YTDL_BIN\"" >> "$SINUS_DIR/config.ini" && \
    cp -f "$SINUS_DIR/plugin/libsoundbot_plugin.so" "$TS3_DIR/plugins/" && \
    chown -fR "$SINUS_USER":"$SINUS_GROUP" "$SINUS_DIR" "$TS3_DIR" && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["$SINUS_DATA"]

EXPOSE 8087

ENTRYPOINT ["/entrypoint.sh"]
