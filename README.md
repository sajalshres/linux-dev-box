# Linux Dev Box
This repository includes the vagrant configuration that reads all your VM configuration from the configuration file `config.yml` and builds and manage the development machine in a single workflow.

## Requirements
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant](https://releases.hashicorp.com/vagrant/2.2.7/vagrant_2.2.7_x86_64.msi)
* [OpenSSH](https://github.com/PowerShell/Win32-OpenSSH/releases)

## Setup
* Install requirements from above.
* Clone or download this project
```bash
git clone git@github.com:sajalshres/linux-dev-box.git
cd linux-dev-box
```
* Create and Configure guest machine
```bash
vagrant up
```
* Run provisioner if required
```bash
vagrant up --provision
# OR
vagrant provision
```

## Note:
> This project is still a Work-In-Progress(WIP)
> We are currently building a script to install all the prerequisites in a single `powershell` or `python` script

## Contributers
1. Sajal Shrestha
2. Binay Shakya
3. Prashant Paudel
