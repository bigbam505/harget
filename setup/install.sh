#!/bin/bash


echo 'Installing some shit'

## Simple disk storage check. Naively assumes root partition holds all system data.
ROOT_AVAIL=$(df -k / | tail -n 1 | awk {'print $4'})
MIN_REQ="512000"

if [ $ROOT_AVAIL -lt $MIN_REQ ]; then
  echo "Insufficient disk space. Make sure you have at least 500MB available on the root partition."
  exit 1
fi

echo "Installing more dependencies..."

sudo pip install -r ./dependencies.txt -q > /dev/null
