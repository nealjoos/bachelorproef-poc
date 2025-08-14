#! /bin/bash
# Replace the addresses line with dhcp4: true
sed -i '/eth1:/,/^[^ ]/ { 
    /addresses:/d
    /-192\.168\.60\.11\/24/d
    /eth1:/a\  dhcp4: true
}' 50-vagrant.yaml
