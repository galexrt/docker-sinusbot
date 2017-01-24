FROM debian:jessie

MAINTAINER Alexander Trost <galexrt@googlemail.com>

ENV SINUS_USER="3000" \
    SINUS_GROUP="3000" \
    SINUS_DIR="/sinusbot" \
    YTDL_BIN="/usr/local/bin/youtube-dl" \
    SINUS_VERSION="0.9.16-10f0fad" \
    YTDL_VERSION="latest" \
    TS3_VERSION="3.1.0.1" \
    TS3_OFFSET="25003"

ENV SINUS_DATA="$SINUS_DIR/data" \
    SINUS_DATA_SCRIPTS="$SINUS_DIR/scripts" \
    TS3_DIR="$SINUS_DIR/TeamSpeak3-Client-linux_amd64"

RUN groupadd -g 3000 sinusbot && \
    useradd -u 3000 -g 3000 -d "$SINUS_DIR" sinusbot && \
    apt-get -q update && \
    apt-get -q upgrade -y && \
    apt-get -q install -y libpulse0 libasound2 locales wget sudo python bzip2 sqlite3 \
        ca-certificates libglib2.0-0 x11vnc xvfb libxcursor1 xcb libnss3 && \
    update-ca-certificates && \
    locale-gen --purge en_US.UTF-8 && \
    echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale && \
    echo "LANG=en_US.UTF-8" >> /etc/default/locale && \
    mkdir -p "$SINUS_DIR" "$TS3_DIR"

RUN wget -qO- "https://www.sinusbot.com/pre/sinusbot-$SINUS_VERSION.tar.bz2" | \
    tar -xjf- -C "$SINUS_DIR" && \
    mv "$SINUS_DATA_SCRIPTS" "$SINUS_DATA_SCRIPTS-orig"

RUN wget -q -O- "http://dl.4players.de/ts/releases/$TS3_VERSION/TeamSpeak3-Client-linux_amd64-$TS3_VERSION.run" | \
    tail -c +$TS3_OFFSET | \
    tar xzf - -C "$TS3_DIR"

RUN wget -q -O "$YTDL_BIN" "https://yt-dl.org/downloads/$YTDL_VERSION/youtube-dl" && \
    chmod 755 -f "$YTDL_BIN"

RUN mv -f "$SINUS_DIR/config.ini.dist" "$SINUS_DIR/config.ini" && \
    sed -i "s|TS3Path = .*|TS3Path = \"$TS3_DIR/ts3client_runscript.sh\"|g" "$SINUS_DIR/config.ini" && \
    echo "YoutubeDLPath = \"$YTDL_BIN\"" >> "$SINUS_DIR/config.ini" && \
    cp -f "$SINUS_DIR/plugin/libsoundbot_plugin.so" "$TS3_DIR/plugins/" && \
    chown -fR sinusbot:sinusbot "$SINUS_DIR" "$TS3_DIR" && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD entrypoint.sh /entrypoint.sh

VOLUME ["$SINUS_DATA", "$SINUS_DATA_SCRIPTS"]

EXPOSE 8087

ENTRYPOINT ["/entrypoint.sh"]
