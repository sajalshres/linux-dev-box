# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

###############################################################################
# Load configuration
###############################################################################
current_dir = File.dirname(File.expand_path(__FILE__))
all_config = YAML.load_file("#{current_dir}/config.yaml")

###############################################################################
# Utility functions
###############################################################################

# Convert the shell provisioner arguments from configuration file
# into an array for the vagrant shell provisioner
def shell_provisioner_args(yaml_arguments)
    shell_arguments = Array.new

    # Arguments may or may not be named,
    # and named arguments may or may not have a value.
    yaml_arguments.each do |argument|
        argument.key?('name') && shell_arguments.push(argument['name'])
        argument.key?('value') && shell_arguments.push(argument['value'])
    end

    shell_arguments
end

###############################################################################
# Vagrant setup functions
###############################################################################

# Setup VM base config
def setup_basic_config(config, vm_config)
    # Vargrant Box
    config.vm.box = vm_config['base_box']
    
    if vm_config['base_box_version'] != 'latest'
        config.vm.box_version = vm_config['base_box_version']
    end

        
    # Vagrant box name
    config.vm.define vm_config['name']

    # Setup virtual machine name
    config.vm.host_name = vm_config['name']

    # Set timeout
    config.vm.boot_timeout = vm_config['boot_timeout']

    # [Optional] Set disk size
    # Note: vagrant plugin install vagrant-disksize
    config.disksize.size = vm_config['disk_size']

    if Vagrant.has_plugin?("vagrant-vbguest")
        config.vbguest.auto_update = false  
    end
end

# Setup provider
def setup_provider(config, vm_config)
    providers = vm_config['providers']
    providers && providers.each do |type, params|
        config.vm.provider type do |provider|
            params.each do |key, value|
                provider.send("#{key}=", value)
            end
        end
    end

    # Provider specific configuration
    config.vm.provider 'virtualbox' do |vb|
        vb.name = vm_config['name']
        vb.customize [ 'modifyvm', :id, '--cpus', vm_config['cpus'] ]
        vb.customize [ 'modifyvm', :id, '--memory', vm_config['memory'] ]
        # Additional customizations
        # Shared clipboard
        vb.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
        # Disable serial port
        vb.customize [ 'modifyvm', :id, '--uartmode1', 'file', File::NULL ]
    end
end

# Setup forwarded ports
def setup_network_forwarded_port(config, ports)
    ports && ports.each do |port|
        config.vm.network :forwarded_port, guest: port['guest'], host: port['host']
    end
end

# Setup ssh
def setup_ssh(config, ssh_config)
    #config.ssh.insert_key = false
    #config.ssh.private_key_path = [
    #    "#{Dir.home}/.vagrant.d/insecure_private_key"
    #]
    config.vm.provision :shell, privileged: false do |provisioner|
        ssh_private_key = File.read(ssh_config['key']['private-key'])
        ssh_pub_key = File.readlines(ssh_config['key']['public-key']).first.strip
        provisioner.inline = <<-SHELL
            if grep -sq "#{ssh_pub_key}" /home/$USER/.ssh/authorized_keys; then
                echo "SSH: keys already provisioned."
            else
                echo "SSH: starting key provisioning"
                mkdir -p /home/$USER/.ssh/
                touch /home/$USER/.ssh/known_hosts
                touch /home/$USER/.ssh/authorized_keys
                echo #{ssh_pub_key} >> /home/$USER/.ssh/authorized_keys
                sudo bash -c "echo #{ssh_pub_key} >> /root/.ssh/authorized_keys"
            fi

            if [ #{ssh_config['key']['copy']} == "true" ]; then
                echo "SSH: copy is set to true, copying key"
                echo "#{ssh_private_key}" > /home/$USER/.ssh/id_rsa
                echo #{ssh_pub_key} > /home/$USER/.ssh/id_rsa.pub
                chmod 600 /home/$USER/.ssh/id_rsa
                chmod 644 /home/$USER/.ssh/id_rsa.pub
            fi
            chown -R $USER:$USER /home/$USER
            exit 0
        SHELL
    end
end

# Setup sync folder
def setup_sync_folder(config, sync_folder_config)
    if sync_folder_config['enable']
        config.vm.synced_folder sync_folder_config['source'],
            sync_folder_config['destination'],
            create: true,
            disabled: sync_folder_config['disabled']
    end
end

# Setup provision
def setup_provisioners(config, provisioners)
    provisioners && provisioners.each do |provisioner|
        provisioner.each do |provisioner_name, provisioner_detail|
            if provisioner_detail['enable']
                if provisioner_detail['type'] == 'shell'
                    if provisioner_detail['arguments']
                        config.vm.provision provisioner_name, 
                            type:"shell", 
                            path: provisioner_detail['path'],
                            :args => shell_provisioner_args(provisioner_detail['arguments']),
                            privileged: provisioner_detail['privileged']
                    else
                        config.vm.provision provisioner_name, 
                            type:"shell", 
                            path: provisioner_detail['path'],
                            privileged: provisioner_detail['privileged']
                    end
                elsif provisioner_detail['type'] == 'file'
                    config.vm.provision provisioner_name,
                    type: "file",
                    source: provisioner_detail['source'],
                    destination: provisioner_detail['destination']
                end
            end
        end
    end
end

###############################################################################
# Configure Vagrant
###############################################################################
Vagrant.configure(all_config['api_version']) do |config|
    # Virtual machine configuration
    vm_config = all_config['vm']
    # SSH config
    ssh_config = vm_config['ssh']
    # Network config
    network_config = vm_config['network']
    # Sync folder config
    sync_folder_config = vm_config['sync-folder']
    # Provision config
    provision_config = all_config['provisioners']
    
    # Setup base config
    setup_basic_config(config, vm_config)
    
    # Setup virtual box provider
    setup_provider(config, vm_config)

    # Setup networking
    setup_network_forwarded_port(config, network_config['ports'])

    # Setup ssh
    # ToDo Write setup_ssh configuration function
    setup_ssh(config, ssh_config)

    # Setup sync folder
    setup_sync_folder(config, sync_folder_config)

    # Setup provisioning
    setup_provisioners(config, provision_config)
end
