#!/bin/bash

echo "Checking for TeamSpeak SinusBot Updates ..."
su -c "$SINUS_DIR/ts3bot -update" "$SINUS_USER"

echo "Starting TeamSpeak SinusBot ..."
su -c "xinit $SINUS_DIR/ts3bot -- /usr/bin/Xvfb :1 -screen 0 800x600x16 -ac" "$SINUS_USER"
