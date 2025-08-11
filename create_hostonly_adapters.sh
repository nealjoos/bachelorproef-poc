#!/bin/bash

set -e

# Define network configurations
declare -A networks
networks["192.168.56.1"]="192.168.56.0 255.255.255.0"
networks["192.168.57.1"]="192.168.57.0 255.255.255.0"
networks["192.168.60.1"]="192.168.60.0 255.255.254.0"

# Function to delete conflicting adapters
delete_conflicting_adapters() {
    for adapter in $(VBoxManage list hostonlyifs | grep "^Name:" | awk '{print $2}'); do
        ip=$(VBoxManage list hostonlyifs | grep -A 10 "Name: *$adapter" | grep "IPAddress:" | awk '{print $2}')
        for host_ip in "${!networks[@]}"; do
            if [[ "$ip" == "$host_ip" ]]; then
                echo "Removing conflicting adapter $adapter with IP $ip..."
                VBoxManage hostonlyif remove "$adapter"
            fi
        done
    done
}

# Function to create adapter
create_adapter() {
    host_ip="$1"
    subnet_info=(${networks[$host_ip]})
    net="${subnet_info[0]}"
    mask="${subnet_info[1]}"

    echo "Creating host-only adapter with IP $host_ip and netmask $mask..."
    adapter_name=$(VBoxManage hostonlyif create | grep -o 'vboxnet[0-9]\+')
    
    VBoxManage hostonlyif ipconfig "$adapter_name" --ip "$host_ip" --netmask "$mask"

    echo "Disabling DHCP for $adapter_name..."
    VBoxManage dhcpserver remove --ifname "$adapter_name" || true

    echo "Adapter $adapter_name configured."
}

# Main logic
echo "Removing any conflicting adapters..."
delete_conflicting_adapters

echo "Creating new host-only networks..."
for ip in "${!networks[@]}"; do
    create_adapter "$ip"
done

echo "All host-only networks created successfully."
