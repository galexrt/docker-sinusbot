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
    echo "=> Scripts directory is marked, scripts were already copied. Nothing to do."
fi

if [ -d "$SINUS_CONFIG" ] && [ -f "$SINUS_CONFIG/config.ini" ]; then
    echo "-> Found config in $SINUS_CONFIG with config.ini directory, linking ..."
    rm -f "$SINUS_DIR/config.ini"
    ln -sf "$SINUS_CONFIG/config.ini" "$SINUS_DIR/config.ini"
    echo "=> Linked $SINUS_CONFIG/config.ini to $SINUS_DIR/config.ini."
else
    echo "-> No $SINUS_CONFIG/config.ini found, not linking."
fi

echo "=> Starting SinusBot (https://sinusbot.com) by Michael Friese ..."
exec "$SINUS_DIR/sinusbot" "$@"
