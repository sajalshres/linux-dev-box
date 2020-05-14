# Linux Dev Box
This repository includes the vagrant configuration that reads all your VM configuration from the configuration file `config.yml` and builds and manage the development machine in a single workflow.

## Requirements
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant](https://releases.hashicorp.com/vagrant/2.2.7/vagrant_2.2.7_x86_64.msi)
* [OpenSSH](https://github.com/PowerShell/Win32-OpenSSH/releases)

## Setup
* Install requirements from above.
* Install vagrant plugins

```bash
# Plugin disk size
vagrant plugin install vagrant-disksize
# Plugin virtual box guest add-on
vagrant plugin install vagrant-vbguest
```

* Clone or download this project
```bash
git clone git@github.com:sajalshres/linux-dev-box.git
cd linux-dev-box
```
* Create `config.yaml` from [config.yaml.example](./config.yaml.example) as per the requirements.
    * On minimum, you need to update following properties:
      * **name**: Preferred name for machine
      * **cpus**: Number of CPUs (Recommended is 2)
      * **memory**: 4096 GB Recommended
      * **ports**: This will allow you to access the port from localhost. If you are running a web server in port 8000, and want to access the same in local browser, you can set host: 8000 and guest: 8000. This will map the port 8000 from the local machine to the vagrant box in port 8000.
      * **ssh**: Generate ssh key in your default location (profile)
      * **provisioners**: They include set of tools that will be installed during provisioning. You can disable each by setting **enable:** `false`
      * **note**: Fot setting git, you'll need to get the token from **GitHub** developer settings. Otherwise, set **git** and **repositories** provisioners to `false`.

* Create and Configure guest machine
```bash
# Same directory where repository is cloned
vagrant up
```
**Note**: If you get error for ubuntu cloud image, update the **base_box_version** from [https://app.vagrantup.com/ubuntu/boxes/bionic64](https://app.vagrantup.com/ubuntu/boxes/bionic64)
* To re-run softwares, run provision as below.
```bash
# Same directory where repository is cloned
vagrant up --provision
# OR
vagrant provision
```

## Note:
> This project is still a Work-In-Progress(WIP)
> We are currently building a script to install all the prerequisites in a single `powershell` or `python` script

## Contributers
1. Sajal Shrestha
