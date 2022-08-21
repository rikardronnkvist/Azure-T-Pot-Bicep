# T-Pot Honeypot in Azure

This will create a [T-Pot Honeypot](https://github.com/telekom-security/tpotce) in Azure based on Debian

# installer.ps1 Powershell Script Workflow

* Get your extenal IP via [ipify](https://www.ipify.org/)
* Deploy [main.bicep](./main.bicep) (with verbose logging)
  * Create Storage Account
  * Create Public IP
  * Create Network Security Group
    * Allow 64294-64297 from your external IP
    * Allow all execept admin interface
  * Create Virtual Network
  * Create Network Interface
  * Create VM
  * Run script [install_tpot.sh](./install_tpot.sh)
    * Install Docker
    * GIT clone [https://github.com/telekom-security/tpotce](https://github.com/telekom-security/tpotce)
    * Install T-Pot with config from [tpot.conf](./tpot.conf)
* Reboot
* Output information

It will take a while for the VM to restart and get all services up and running

Usernames and password for the web interface can be found in the file [tpot.conf](./tpot.conf)
