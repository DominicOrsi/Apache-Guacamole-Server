#!/bin/bash

set -eu -o pipefail # fail on error and report it, debug all lines

sudo -n true
test $? -eq 0 || exit 1 "YOU SHOULD HAVE SUDO PRIVILEGE TO RUN THIS SCRIPT"

sudo apt-get update
sudo apt upgrade -y

while read -r p ; do sudo apt-get install -y $p ; done < <(cat << "EOF"
        make
        g++
        gcc
        curl
        openjdk-11-jdk
        libcairo2-dev
        libjpeg-turbo8-dev
        libtool-bin
        uuid-dev
        libossp-uuid-dev
        freerdp2-dev
        libpango1.0-dev
        libssh2-1-dev
        libvncserver-dev
        libpulse-dev
        libssl-dev
        libvorbis-dev
        libwebp-dev
EOF
)

# Packages unable to install
# libpng12-dev

# Checking to see if the /opt/tomcat exists
if [ -d /opt/tomcat ]; then
        echo "DIRECTORY /OPT/TOMCAT EXISTS"
else
        echo "DIRECTORY /OPT/TOMCAT DOES NOT EXIST, CREATING IT"
        sudo mkdir /opt/tomcat
fi

if [ -d /opt/tomcat/tomcatapp ]; then
        echo "DIRECTORY /OPT/TOMCAT/TOMCATAPP EXISTS"
else
        echo "DIRECTORY /OPT/TOMCAT/TOMCATAPP DOES NOT EXIST, CREATING IT"
        sudo mkdir /opt/tomcat/tomcatapp
fi

# Checking to see if Apache-Tomcat is already downloaded
if [ -f apache-tomcat-9.0.68.tar.gz ]; then
        echo "APACHE-TOMCAT IS ALREADY DOWNLOADED"
else
        echo "DOWNLOADING APACHE-TOMCAT"
        wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.68/bin/apache-tomcat-9.0.68.tar.gz
        sudo tar -xzf apache-tomcat-9.0.68.tar.gz
        cp -r apache-tomcat-9.0.68/. /opt/tomcat/tomcatapp
fi

# Creating group tomcat
if [ $(getent group tomcat) ]; then
        echo "GROUP TOMCAT EXISTS"
else
        echo "TOMCAT IS NOT A GROUP, CREATING GROUP"
        sudo groupadd tomcat
fi

# Checking if the user exists
if id -u tomcat >/dev/null 2>&1; then
        echo "TOMCAT IS ALREADY A USER"
else
        echo "TOMCAT IS NOT A USER, CREATING IT"
        sudo useradd -s /sbin/nologin -g tomcat -d /opt/tomcat tomcat
        echo "SET TOMCAT USER PASSWORD"
        passwd tomcat
fi

if [ -d /opt/tomcat/tomcatapp/webapps ]; then
        echo "DIRECTORY /OPT/TOMCAT/TOMCATAPP/WEBAPPS EXISTS"
else
        echo "DIRECTORY /OPT/TOMCAT/TOMCATAPP/WEBAPPS DOESN'T EXIST, CREATING IT"
        sudo mkdir /opt/tomcat/tomcatapp/webapps
fi

# Adding to path NOT WORKING
echo "export JAVA_HOME=$PATH:/usr/lib/jvm/java-11-openjdk-amd64/bin/" | sudo tee -a ~/.bashrc
echo "export CATALINA_HOME=$PATH:/opt/tomcat/tomcatapp/bin/" | sudo tee -a ~/.bashrc

# Allowing user tomcat to own /opt/tomcat
sudo chown -R tomcat.tomcat /opt/tomcat/
sudo chmod 775 /opt/tomcat/tomcatapp/webapps

sudo find /opt/tomcat/tomcatapp/bin -type f -iname "*.sh" -exec chmod +x {} \;
sudo cp tomcat.service /etc/systemd/system/tomcat.service
sudo systemctl daemon-reload
sudo systemctl enable --now tomcat
sudo ufw allow 8080/tcp

# Setting up Guacamole Server
echo Setting up Guacamole Server
if [ -f guacamole-server-1.4.0.tar.gz ]; then
        echo "APACHE-GUACAMOLE-SERVER IS DOWNLOADED"
else
        echo "APACHE-GAUCAMOLE-SERVER IS NOT DOWNLOADED, DOWNLOADING"
        wget https://downloads.apache.org/guacamole/1.4.0/source/guacamole-server-1.4.0.tar.gz
        tar -xzf guacamole-server-1.4.0.tar.gz
fi

cd guacamole-server-1.4.0/
echo Configuring and installing
./configure --with-init-dir=/etc/init.d
sudo make
sudo make install
sudo ldconfig

# Getting back to main directory
cd /home/master/Apache-Guac

# Starting Guacamole Server
sudo systemctl daemon-reload
sudo systemctl start guacd
sudo systemctl enable guacd

# Setting up Guacamole Client

# Checking to see if the directory /etc/guacamole exists
if [ -d /etc/guacamole ]; then
        echo "DIRECTORY /ETC/GUACAMOLE EXISTS"
else
        echo "DIRECTORY /ETC/GUACAMOLE DOESN'T EXISTS"
        sudo mkdir /etc/guacamole
fi

# Checking to see if guacamole-1.4.0.war is downloaded
if [ -f guacamole-1.4.0.war ]; then
        echo "GUACAMOLE.WAR FILE EXISTS"
else
        echo "GUACAMOLE.WAR FILE DOESN'T EXISTS, DOWNLOADING IT"
        wget https://downloads.apache.org/guacamole/1.4.0/binary/guacamole-1.4.0.war
        sudo cp guacamole-1.4.0.war /etc/guacamole/guacamole.war
fi

# Checking for symbolic link
if [[ -L /opt/tomcat/tomcatapp/webapps ]]; then
        echo "/OPT/TOMCAT/TOMCATAPPS/WEBAPPS HAS A SYMBOLIC LINK"
else
        echo "/OPT/TOMCAT/TOMCATAPPS/WEBAPPS DOESN'T HAVE A SYMBOLIC LINK, LINKNG IT TO /ETC/GUACAMOLE/GUACAMOLE.WAR"
        sudo ln -s /etc/guacamole/guacamole.war /opt/tomcat/tomcatapp/webapps
fi


########################################################
#  Configuring Guacamole Server
########################################################
echo "GUACAMOLE_HOME=/etc/guacamole" | sudo tee -a /etc/default/tomcat
echo "export GUACAMOLE_HOME=/etc/guacamole" | sudo tee -a /etc/profile
sudo cp guacamole.properties /etc/guacamole/guacamole.properties

# DOESN'T ENTIRELY WORK -_-
# Checking for symbolic link
if [[ -L /opt/tomcat/tomcatapp/.guacamole ]]; then
        echo "/OPT/TOMCAT/TOMCATAPPS/.GUACAMOLE HAS A SYMBOLIC LINK"
else
        echo "/OPT/TOMCAT/TOMCATAPPS/.GUACAMOLE DOESN'T HAVE A SYMBOLIC LINK, LINKNG IT TO /ETC/GUACAMOLE"
        sudo ln -s /etc/guacamole.guacamole /opt/tomcat/tomcatapp/.guacamole
fi
sudo chown -R tomcat: /opt/tomcat

# echo "SETTING VNCPASSWD, NO VIEW-ONLY PW"
# vncpasswd

# echo "STARTING VNC SERVER"
# vncserver

# Setting up Guacamole Authentication Method
# echo -n DefaultPW | openssl md5
sudo cp user-mapping.xml /etc/guacamole/user-mapping.xml
sudo systemctl restart tomcat guacd