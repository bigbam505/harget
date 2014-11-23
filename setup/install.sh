#!/bin/bash


echo 'Installing some shit'

## Simple disk storage check. Naively assumes root partition holds all system data.
ROOT_AVAIL=$(df -k / | tail -n 1 | awk {'print $4'})
MIN_REQ="512000"

if [ $ROOT_AVAIL -lt $MIN_REQ ]; then
  echo "Insufficient disk space. Make sure you have at least 500MB available on the root partition."
  exit 1
fi

echo "Updating system package database..."
sudo apt-get -qq update > /dev/null

echo "Upgrading the system..."
echo "(This might take a while.)"
#sudo apt-get -y -qq upgrade > /dev/null

echo "Installing system dependencies..."
sudo apt-get -y -qq install git-core python-pip vim supervisor > /dev/null


# Setup the app location
mkdir ~/harget > /dev/null
chown pi ~/harget > /dev/null
git clone https://github.com/bigbam505/harget.git ~/harget > /dev/null


echo "Installing more dependencies..."
sudo pip install -r ~/harget/dependencies.txt -q > /dev/null

cp ~/harget/setup/config.yaml ~/harget/service.yaml

sudo mkdir /var/log/harget-server
sudo chown pi:pi /var/log/harget-server

echo "Setup server to run automagically at startup"
sudo ln -s ~/harget/setup/supervisor_harget_server.conf /etc/supervisor/conf.d/harget_server.conf
sudo /etc/init.d/supervisor stop > /dev/null
sudo /etc/init.d/supervisor start > /dev/null
