#!/bin/bash

if [ "$DEBUG" == "True" ] || [ "$DEBUG" == "true" ]; then
    set -xe
    sed -i 's/LogLevel.*/LogLevel = 10/g' "$SINUS_DIR/config.ini"
fi

echo "-> Checking if scripts directory is empty"
if [ ! -f "$SINUS_DATA_SCRIPTS/.docker-sinusbot-installed" ]; then
    echo "-> Copying original sinusbot scripts to volume ..."
    cp -af "$SINUS_DATA_SCRIPTS-orig/"* "$SINUS_DATA_SCRIPTS"
    touch "$SINUS_DATA_SCRIPTS/.docker-sinusbot-installed"
    echo "=> Sinusbot scripts copied."
else
    echo "=> Scripts directory is marked, scripts wre already copied. Nothing to do."
fi

echo "=> You are good to go! You are already using the new data directory, located at \"$SINUS_DATA\"."

echo "=> Starting SinusBot (https://sinusbot.com) by Michael Friese ..."
exec "$SINUS_DIR/sinusbot" "$@"
