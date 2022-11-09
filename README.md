# Apache-Guacamole-Server
A server that allows users to connect to another machine using their browser.

## Setup
Requirements:
- Ubuntu 20.04 LTS
- Internet

## How to Install
Clone the repository to the machine you want to install the server on. The simply check to make sure that the account in the __install.sh__ file is the same as the account installing it. Right now the account is _master_.

Run the script with 
```bash
sudo bash install.sh
```

### Asked for input
You will be asked to setup the password of the tomcat account, chose any password you want but remember to right it down.

After that the script should be done installing and setting up tomcat and guacamole.

## Accessing the Webpage
To check that the webpage is up, type in the servers ip address, then port 8080, and /guacamole. <ip_addr>:8080/guacamole

