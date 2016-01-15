#!/bin/bash

echo "Removing /tmp/.X1-lock, if existing"
rm -f /tmp/.X1-lock

echo "Correcting mount point permissions ..."
chown "$SINUS_USER":"$SINUS_GROUP" -R "$SINUS_DATA"

echo "Checking for TeamSpeak SinusBot Updates ..."
sudo -u "$SINUS_USER" -g "$SINUS_GROUP" "$SINUS_DIR/ts3bot" -update

echo "Starting TeamSpeak SinusBot ..."
sudo -u "$SINUS_USER" -g "$SINUS_GROUP" xinit "$SINUS_DIR/ts3bot" -- /usr/bin/Xvfb :1 -screen 0 800x600x16 -ac
