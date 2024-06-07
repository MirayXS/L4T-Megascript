#!/bin/bash

cd
clear -x
echo "Moonlight script started!"
if [[ $jetson_model ]]; then
  # remove old moonlight name and repo
  sudo rm -rf /etc/apt/sources.list.d/moonlight-l4t.list
  sudo apt remove moonlight -y

  curl -1sLf 'https://dl.cloudsmith.io/public/moonlight-game-streaming/moonlight-l4t/setup.deb.sh' | sudo -E bash
  sudo apt install moonlight-qt -y || error "Failed to install Moonlight!"
else
  if [[ $dpkg_architecture == "amd64" ]]; then
    ubuntu_ppa_installer "alexlarsson/flatpak" || error "PPA failed to install"
    sudo apt install flatpak -y
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo flatpak install flathub com.moonlight_stream.Moonlight -y || error "Failed to install Moonlight!"
  else
    error_user "Error: your userspace architecture ($dpkg_architecture) is not supported by Moonlight (or we don't know how to install) and will fail to run"
  fi
fi

echo "Done!"
echo "Ctrl + click this link before this message disappears in 20 seconds"
echo "For a guide on how to set Moonlight up on your PC and connect"
echo "to it from your $jetson_model $dpkg_architecture device!"
echo
echo "https://github.com/moonlight-stream/moonlight-docs/wiki/Setup-Guide"
echo
echo "Remember that you must have a computer"
echo "on the same network with a capable Nvidia GPU to run this."
echo "The program on your Switch can be run from"
echo "your apps list or by typing 'moonlight-qt' into a terminal."
sleep 20
echo "Going back to the menu..."
sleep 2
