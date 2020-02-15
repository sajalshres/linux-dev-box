# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

# Load config
current_dir = File.dirname(File.expand_path(__FILE__))
config = YAML.load_file("#{current_dir}/config.yaml")

# Virtual machine configuration
vm_config = config['vm']

# User config
user_config = config['user']


# Configure Vagrant
Vagrant.configure(config['api_version']) do |config|
    # Vargrant Box
    config.vm.box = vm_config['base_box']
    
    # Vagrant box name
    config.vm.define vm_config['name']

    # Set virtual machine name
    config.vm.host_name = vm_config['name']

    # [Optional] Set disk size
    # Note: vagrant plugin install vagrant-disksize
    config.disksize.size = vm_config['disk_size']
    
    # Setup virtual box provider
    config.vm.provider "virtualbox" do |vb|
        vb.name = vm_config['name']
        vb.gui = vm_config['gui']
        vb.cpus = vm_config['cpus']
        vb.memory = vm_config['memory']
        # Additional customizations
        # Shared clipboard
        vb.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
    end

    # Setup networking
    config.vm.network :forwarded_port, guest: 8000, host: 8000

    # Setup provisioning

    # Setup base provisioning
    config.vm.provision "base", before: :all, type: "shell", path: "provision/base.sh"

    # Setup python development provisioning
    config.vm.provision "python", type: "shell", path: "provision/python.sh"

    # Setup docker provisioning
    config.vm.provision "docker", type:"shell", path: "provision/docker.sh"
    
    # Setup web development provisioning
    config.vm.provision "web-development", type:"shell", path: "provision/web-development.sh"

    # Setup web development provisioning
    config.vm.provision "desktop", type:"shell", path: "provision/desktop.sh"

    # Setup user provisioning
    # config.vm.provision "user", type:"shell", path: "provision/user.sh", :args => [USER_NAME, USER_UID, USER_GID]

    # Setup clean up of provisioning
    config.vm.provision "clean-up", after: :all, type:"shell", path: "provision/clean-up.sh"
end

