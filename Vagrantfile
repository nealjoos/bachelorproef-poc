# One Vagrantfile to rule them all!
#
# This is a generic Vagrantfile that can be used without modification in
# a variety of situations. Hosts and their properties are specified in
# `vagrant-hosts.yml`. Provisioning is done by a shell script in the directory
# PROVISIONING_SCRIPT_DIR with the same name as the host name.
#
# Author: Bert Van Vreckem <https://github.com/bertvv>
#
# See https://github.com/bertvv/vagrant-shell-skeleton/ for details
#

require 'rbconfig'
require 'yaml'

# set default LC_ALL for all BOXES
ENV["LC_ALL"] = "en_US.UTF-8"

# Set your default base box here
DEFAULT_BASE_BOX = 'almalinux/9'

# Directory containing VM provisioning scripts
PROVISIONING_SCRIPT_DIR = 'scripts/'

#
# No changes needed below this point
#

VAGRANTFILE_API_VERSION = '2'
PROJECT_NAME = '/' + File.basename(Dir.getwd)

hosts = YAML.load_file('vagrant-hosts.yml')

# {{{ Helper functions

def windows_host?
  Vagrant::Util::Platform.windows?
end

def custom_synced_folders(vm, host)
  return unless host.key?('synced_folders')
  folders = host['synced_folders']

  folders.each do |folder|
    vm.synced_folder folder['src'], folder['dest'], folder['options']
  end
end

# Adds forwarded ports to your Vagrant machine
#
# example:
#  forwarded_ports:
#    - guest: 88
#      host: 8080
def forwarded_ports(vm, host)
  if host.has_key?('forwarded_ports')
    ports = host['forwarded_ports']

    ports.each do |port|
      vm.network "forwarded_port", guest: port['guest'], host: port['host']
    end
  end
end

# }}}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  hosts.each do |host|
    config.vm.define host['name'] do |node|
      node.vm.box = host['box'] ||= DEFAULT_BASE_BOX
      node.vm.box_url = host['box_url'] if host.key? 'box_url'

      node.vm.hostname = host['name']

      if host.key?('networks')
        host['networks'].each do |net|
          type = net['type'].to_sym

          options = net.each_with_object({}) do |(k, v), memo|
            memo[k.to_sym] = v unless k == 'type'
          end

          if type == :private_network
            if !options.key?(:ip)
              # DHCP
              node.vm.network type, type: 'dhcp'
              next
            else
              # Static IP
              options[:netmask] ||= '255.255.255.0'
            end
          end

          node.vm.network type, **options
        end
      end

      # Disable default Vagrant synced folder if specified
      if host['disable_default_vagrant']
        node.vm.synced_folder '.', '/vagrant', disabled: true
      end

      custom_synced_folders(node.vm, host)
      forwarded_ports(node.vm, host) 

      # Use custom login name/password if specified
      node.ssh.username = host['ssh_username'] if host.key? 'ssh_username'
      node.ssh.password = host['ssh_password'] if host.key? 'ssh_password'

      # Add VM to a VirtualBox group
      node.vm.provider :virtualbox do |vb|
        vb.memory = host['memory'] if host.key? 'memory'
        vb.cpus = host['cpus'] if host.key? 'cpus'

        # WARNING: if the name of the current directory is the same as the
        # host name, this will fail.
        vb.customize ['modifyvm', :id, '--groups', PROJECT_NAME]
      end
            
      # Run provisioning script for the VM, if it exists.
      provisioning_script = PROVISIONING_SCRIPT_DIR + host['name'] + '.sh'
      if File.exist?(provisioning_script)
        node.vm.provision 'shell', path: provisioning_script
      else
        node.vm.post_up_message = "WARNING! No provisioning script found for #{host['name']}"
      end
    end
  end
end

# -*- mode: ruby -*-
# vi: ft=ruby :
