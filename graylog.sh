#!/bin/bash

# Pobieranie wszystkich potrzebnych elementów
sudo timedatectl set-timezone Europe/Warsaw
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y docker-compose nano apache2 samba python3-venv net-tools
sudo usermod -aG docker $USER

# Utworzenie katalogu graylog
sudo mkdir /graylog
sudo chmod 777 /graylog
echo "Utworzono katalog /graylog z uprawnieniami 777."

# Pobranie pliku docker-compose do folderu /graylog
cd /graylog
sudo wget https://raw.githubusercontent.com/mateuszkopa/graylogwindows/refs/heads/main/docker-compose.yml 
nano docker-compose.yml


# Przejcie do folderu apache
chmod 777 /var/www/html/
cd /var/www/html/
echo "Przejście do katalogu /var/www/html/."
rm index.html

# Utworzenie folderów dla plików konfiguracyjnych nxloga
mkdir install
chmod 777 install
mkdir koncowki
chmod 777 koncowki
mkdir serwery
chmod 777 serwery
echo "Utworzenie folderów koncowki i serwery"

# Pobranie konfiguracji nxloga dla końcówek do /var/www/html/koncowki
cd install
wget https://raw.githubusercontent.com/mateuszkopa/graylogwindows/refs/heads/main/nxlog.msi
wget https://raw.githubusercontent.com/mateuszkopa/graylogwindows/refs/heads/main/Sysmon64.exe
wget https://raw.githubusercontent.com/olafhartong/sysmon-modular/master/sysmonconfig.xml
cd ..
cd koncowki
sudo wget https://raw.githubusercontent.com/mateuszkopa/graylogwindows/refs/heads/main/koncowki/nxlog.conf

# Edycja pliku konfiguracyjnego nxloga dla koncowek
sudo nano nxlog.conf

# Pobranie konfiguracji nxloga dla serwerów do /var/www/html/serwery
cd ..
cd serwery
sudo wget https://raw.githubusercontent.com/mateuszkopa/graylogwindows/refs/heads/main/serwery/nxlog.conf

# Edycja pliku konfiguracyjnego nxloga dla serwerow
sudo nano nxlog.conf

# SAMBA
wget https://raw.githubusercontent.com/mateuszkopa/graylogwindows/refs/heads/main/samba.sh
sudo chmod 777 samba.sh
sudo ./samba.sh
wait

# Uruchomienie grayloga
cd /graylog
sudo docker-compose up -d

# Zmiana adresów IP
read -p "Czy ustawić adres IP (T/N): " answer

if [ "$answer" == "T" ]; then
read -p "Podaj adres IP: " ip_address
read -p "Podaj maskę: " subnet_mask
read -p "Podaj gatewaya: " gateway
read -p "Podaj DNS: " dns1 dns2
ifconfig eth0 $ip_address netmask $subnet_mask up
route add default gw $gateway
echo "nameserver $dns1" | sudo tee -a /etc/resolv.conf
echo "nameserver $dns2" | sudo tee -a /etc/resolv.conf
fi

echo "Skrypt zakończony."