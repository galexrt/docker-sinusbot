# SinusBot

FROM ubuntu
MAINTAINER buschtoens

# SinusBot config
ENV SINUS_VERSION 0.9.8
ENV SINUS_DIR /opt/ts3soundboard
ENV SINUS_DATA /opt/data

# TeamSpeak 3 client config
ENV TS3_VERSION 3.0.16
ENV TS3_OFFSET 49134
ENV TS3_DIR $SINUS_DIR/TeamSpeak3-Client-linux_amd64

# Install apt-get dependencies
RUN apt-get update && apt-get install -y \
  wget \
  screen \
  x11vnc \
  xinit \
  xvfb \
  libxcursor1 \
  ca-certificates
RUN update-ca-certificates

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
RUN echo DataDir = \"$SINUS_DATA\" >> ./config.ini

# Download and install the TeamSpeak 3 client
RUN wget -qO- http://dl.4players.de/ts/releases/$TS3_VERSION/TeamSpeak3-Client-linux_amd64-$TS3_VERSION.run | \
  tail -c +$TS3_OFFSET | \
  tar -xzf- -C $TS3_DIR
RUN cp ./plugin/libsoundbot_plugin.so ./TeamSpeak3-Client-linux_amd64/plugins

# Copy start script
COPY start.sh ./
RUN chmod +x ./start.sh

VOLUME $SINUS_DATA

# Expose web control panel
EXPOSE 8087

# Run script
ENV LC_ALL en_US.UTF-8
CMD ["./start.sh"]
