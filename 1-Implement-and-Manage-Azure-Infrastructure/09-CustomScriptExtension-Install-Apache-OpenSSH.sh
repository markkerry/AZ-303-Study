#!/bin/bash
sleep 20s
apt-get update
apt-get install stress -y
apt-get install apache2 -y
ufw allow 'Apache Full'
ufw allow 'OpenSSH'
ufw enable