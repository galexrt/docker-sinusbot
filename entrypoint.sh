#!/bin/bash

if [ "$DEBUG" == "True" ] || [ "$DEBUG" == "true" ]; then
    set -x
    set -e
    sed -i 's/LogLevel.*/LogLevel = 10/g' "$SINUS_DIR/config.ini"
fi

echo "Correcting mount point permissions ..."
chown "$SINUS_USER":"$SINUS_GROUP" -R "$SINUS_DATA"

echo "Starting TeamSpeak SinusBot ..."
exec sudo -u "$SINUS_USER" -g "$SINUS_GROUP" "$SINUS_DIR/sinusbot"
