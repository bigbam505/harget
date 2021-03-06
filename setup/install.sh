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
sudo apt-get -y -qq install git-core python-pip vim supervisor uzbl > /dev/null


# Setup the app location
install_directory="$HOME/harget"
if [ ! -d "$install_directory" ]; then
  mkdir "$install_directory"  > /dev/null
  chown pi:pi "$install_directory" > /dev/null
  git clone https://github.com/bigbam505/harget.git "$install_directory" > /dev/null
fi

echo "Installing more dependencies..."
sudo pip install -r "$install_directory/dependencies.txt" -q > /dev/null

cp "$install_directory/setup/config.yaml" "$install_directory/service.yaml"

echo "Setup the logging files"
harget_log="/var/log/harget"
if [ ! -d "$harget_log" ]; then
  sudo mkdir "$harget_log"
fi
sudo chown pi:pi "$harget_log"

# Lets create some log folders
if [ ! -d "$harget_log/server" ]; then
  mkdir "$harget_log/server"
fi

if [ ! -d "$harget_log/viewer" ]; then
  mkdir "$harget_log/viewer"
fi

echo "Setup the html folder in tmp"
harget_files="/var/harget"
if [ ! -d "$harget_files" ]; then
  sudo mkdir "$harget_files"
fi

sudo chown pi:pi "$harget_files"
ln -sf "$install_directory/html" "$harget_files/html"

echo "Setup some configuration files for the viewer"
ln -sf "$install_directory/setup/uzbl.rc" "$HOME/.uzbl.rc"

echo "Setup server to run automagically at startup"
sudo ln -sf "$install_directory/setup/supervisor_harget_server.conf" /etc/supervisor/conf.d/harget_server.conf
sudo /etc/init.d/supervisor stop > /dev/null
sudo /etc/init.d/supervisor start > /dev/null

echo "Setup viewer to run automagically at startup"
mkdir -p ~/.config/lxsession/LXDE/
echo "@$install_directory/setup/autostart.sh" > ~/.config/lxsession/LXDE/autostart

if [ -d "/etc/xdg/lxsession/LXDE/autostart" ]; then
  echo 'test'
  #sudo mv /etc/xdg/lxsession/LXDE/autostart /etc/xdg/lxsession/LXDE/autostart.bak
fi

