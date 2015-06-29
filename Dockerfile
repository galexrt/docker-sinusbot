# SinusBot

FROM debian
MAINTAINER buschtoens

# SinusBot config
ENV SINUS_VERSION 0.9.8
ENV SINUS_DIR /opt/ts3soundboard
ENV SINUS_DATA /opt/data

# TeamSpeak 3 client config
ENV TS3_VERSION 3.0.16
ENV TS3_OFFSET 49134
ENV TS3_DIR $SINUS_DIR/TeamSpeak3-Client-linux_amd64

# youtube-dl config
ENV YTDL_VERSION 2015.06.25
ENV YTDL_BIN /usr/local/bin/youtube-dl

# Install apt-get dependencies
RUN apt-get update && apt-get install -y \
  wget \
  screen \
  x11vnc \
  xinit \
  xvfb \
  libxcursor1 \
  libglib2.0-0 \
  python \
  bzip2 \
  ca-certificates
RUN update-ca-certificates

# Install youtube-dl 
RUN wget -qO $YTDL_BIN https://yt-dl.org/downloads/$YTDL_VERSION/youtube-dl
RUN chmod a+rx $YTDL_BIN

# Set default locale
RUN echo LC_ALL=en_US.UTF-8 >> /etc/default/locale
RUN echo LANG=en_US.UTF-8 >> /etc/default/locale

# Create working directories and setup user
RUN groupadd -r sinusbot && useradd -r -g sinusbot sinusbot
RUN mkdir -p $SINUS_DIR && chown sinusbot:sinusbot $SINUS_DIR
RUN mkdir -p $SINUS_DATA && chown sinusbot:sinusbot $SINUS_DATA
RUN mkdir -p $TS3_DIR && chown sinusbot:sinusbot $TS3_DIR
WORKDIR $SINUS_DIR
USER sinusbot

# Download and install the SinusBot
RUN wget -qO- http://frie.se/ts3bot/sinusbot-$SINUS_VERSION.tar.bz2 | \
  tar -xjf- -C ./
RUN cp ./config.ini.dist ./config.ini
RUN echo YoutubeDLPath = \"$YTDL_BIN\" >> ./config.ini

# Download and install the TeamSpeak 3 client
RUN wget -qO- http://dl.4players.de/ts/releases/$TS3_VERSION/TeamSpeak3-Client-linux_amd64-$TS3_VERSION.run | \
  tail -c +$TS3_OFFSET | \
  tar -xzf- -C $TS3_DIR
RUN cp ./plugin/libsoundbot_plugin.so ./TeamSpeak3-Client-linux_amd64/plugins

VOLUME $SINUS_DIR

# Expose web control panel
EXPOSE 8087

# Run script
CMD ["xinit" ,"/opt/ts3soundboard/ts3bot", "--", "/usr/bin/Xvfb", ":1", "-screen", "0", "800x600x16", "-ac"]
