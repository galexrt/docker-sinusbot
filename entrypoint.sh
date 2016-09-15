#!/bin/bash

if [ "$DEBUG" == "True" ] || [ "$DEBUG" == "true" ]; then
    set -x
    set -e
    sed -i 's/LogLevel.*/LogLevel = 10/g' "$SINUS_DIR/config.ini"
fi

if [ "$SINUS_USER" != "3000" ]; then
    usermod -u "$SINUS_USER" sinusbot
fi
if [ "$SINUS_GROUP" != "3000" ]; then
    groupmod -g "$SINUS_GROUP" sinusbot
fi

if [ ! -d "$SINUS_DATA/scripts" ]; then
    mv "$SINUS_DIR/scripts" "$SINUS_DATA/scripts"
fi
ln -s "$SINUS_DATA/scripts" "$SINUS_DIR/scripts"

echo "Correcting file and mount point permissions ..."
chown -fR sinusbot:sinusbot "$SINUS_DIR" "$TS3_DIR"
chown sinusbot:sinusbot -R "$SINUS_DATA"

echo "Starting TeamSpeak SinusBot ..."
exec sudo -u sinusbot -g sinusbot "$SINUS_DIR/sinusbot"
