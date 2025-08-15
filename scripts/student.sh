#! /bin/bash
# Replace the addresses line with dhcp4: true
sed -i '/eth1:/,/^[^ ]/ {
    /addresses:/d
    /^  - /d
    /eth1:/a\  dhcp4: true
}' /etc/netplan/50-vagrant.yaml

# Replace XKBLAYOUT line to set Belgian layout
sudo sed -i 's/^XKBLAYOUT=.*/XKBLAYOUT="be"/' /etc/default/keyboard