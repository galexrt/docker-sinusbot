# SinusBot

FROM ubuntu
MAINTAINER buschtoens

# SinusBot config
ENV SINUS_VERSION 0.9.8
ENV SINUS_DIR /opt/ts3soundboard
ENV SINUS_TAR /tmp/sinusbot.tar.bz2

# TeamSpeak 3 client config
ENV TS3_VERSION 3.0.16
ENV TS3_RUN /tmp/teamspeak-client.run

# Install apt-get dependencies
RUN apt-get update && apt-get install -y \
  wget \
  screen \
  x11vnc \
  xinit \
  xvfb \
  libxcursor1 \
  ca-certificates \
  bzip2
RUN update-ca-certificates

# Download and install the SinusBot
RUN wget -O $SINUS_TAR http://frie.se/ts3bot/sinusbot-$SINUS_VERSION.tar.bz2
RUN mkdir -p $SINUS_DIR
RUN tar -xjf $SINUS_TAR -C $SINUS_DIR
RUN rm $SINUS_TAR
RUN cp $SINUS_DIR/config.ini.dist $SINUS_DIR/config.ini
RUN echo DataDir = \"/opt/data\" >> $SINUS_DIR/config.ini

# Download and install the TeamSpeak 3 client
RUN wget -O $TS3_RUN http://dl.4players.de/ts/releases/$TS3_VERSION/TeamSpeak3-Client-linux_amd64-$TS3_VERSION.run
RUN chmod +x $TS3_RUN
RUN screen -dmS installation sh -c "cd $SINUS_DIR; $TS3_RUN"
RUN sleep 1 && screen -S installation -p 0 -X stuff "$(printf \\r)"  # open license
RUN sleep 1 && screen -S installation -p 0 -X stuff "q"             # close license
RUN sleep 1 && screen -S installation -p 0 -X stuff "y$(printf \\r)" # accept license
RUN sleep 1 && rm $TS3_RUN
RUN cp $SINUS_DIR/plugin/libsoundbot_plugin.so $SINUS_DIR/TeamSpeak3-Client-linux_amd64/plugins

WORKDIR $SINUS_DIR

VOLUME /opt/data

# Expose web control panel
EXPOSE 8087

# Run script
ENTRYPOINT ["xinit", "/opt/ts3soundboard/ts3bot", "--", "/usr/bin/Xvfb"]
CMD [":1", "-screen", "0", "800x600x16", "-ac"]
