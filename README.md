# Linux Dev Box
This repository includes the vagrant configuration that reads all your VM configuration from the configuration file `config.yml` and builds and manage the development machine in a single workflow.

This development environment is supposed to be **immutable**, meaning once you create it, you never change it. For a new version you destroy the older one.

## Requirements [as tested]
* [VirtualBox 6.0.16](https://download.virtualbox.org/virtualbox/6.0.16/VirtualBox-6.0.16-135674-Win.exe)
* [Vagrant 2.2.10](https://releases.hashicorp.com/vagrant/2.2.10/vagrant_2.2.10_x86_64.msi)
* [OpenSSH](https://github.com/PowerShell/Win32-OpenSSH/releases)

## Setup
* Install requirements from above.
* Install vagrant plugins

```bash
# Launch terminal and install vagrant plugin as below
# Plugin disk size
$ vagrant plugin install vagrant-disksize
# Plugin virtual box guest add-on
$ vagrant plugin install vagrant-vbguest
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
**KNOWN ISSUES**
If the command line gets stuck in  "ssh auth method: private key" or get  "time out while waiting for the machine to boot",
try reducing the number of cpus to 1 under vm in your config.yaml file.


## GUI

To launch in dev box in GUI:

* Launch Virtulbox, it will list your machine running.
* Click `show` icon
* Login with `vagrant` user. **Note**: pass is same.
* On first boot, Desktop will ask for configuration, choose default.

## SSH to Box

```
$ ssh vagrant@localhost -p 2222
```

## VSCode Remote Development

* Launch vscode
* Install `Remote Development` pack or just `Remote - SSH`
* Open command palette by clicking view -> `Command Palette...` or `ctrl` + `shift` + `p`
* Type and select: `Remote-SSH: Open Configuration File`
* Select the default or user configuration file
* And content as below:

```
Host You-Machine-Name
    HostName localhost
    User vagrant
    Port 2222
```

* Open command palette by clicking view -> `Command Palette...` or `ctrl` + `shift` + `p`
* Type and select: `Remote-SSH: Connect to host`

## Verification

* Launch a terminal
* Verify evrything is installed as below:

```shell
$ node -v
v13.14.0

$ npm -v
6.14.4

$ docker --version

Docker version 19.03.8, build afacb8b7f0

$ docker-compose --version
docker-compose version 1.25.3, build d4d1b42b

$ python3.7 --version
Python 3.7.7

ls ~/Git/

# If git was enabled in config file
$ ssh -T git@github.com
Hi sajalshres! You've successfully authenticated, but GitHub does not provide shell access.
```

## Note:
> This project is still a Work-In-Progress(WIP)
> We are currently building a script to install all the prerequisites in a single `powershell` or `python` script

## Known Issues

- Vagrant not working with latest version on VirtualBox, revert back to version mentioned in **Requirement**

- Virutal Box incompatible with Windows Hypervisor. Disable the windows hypervisor platform.

## Contributers
1. Sajal Shrestha
