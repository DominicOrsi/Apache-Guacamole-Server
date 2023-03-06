# Apache-Guacamole-ServerA server that allows users to connect to another machine using their browser

## SetupRequirements:
- Ubuntu 20.04 LTS
- Internet

## How to Install
Clone the repository to the machine you want to install the server on. Then, simply check to make sure that the account in the __install.sh__ file is the same as the account installing it. Right now the account is _master_.
Run the script with
```bash
sudo bash install.sh
```

### Asked for input
You will be asked to set up the password for the tomcat account; choose any password you want but remember to write it down. After that, the script should be done installing and setting up tomcat and guacamole.
## Accessing the Webpage
To check that the webpage is up, type in the server's IP address, then port 8080, and /guacamole. <ip_addr>:8080/guacamole
 
