#!/bin/bash

# Pobieranie wszystkich potrzebnych elementów
sudo timedatectl set-timezone Europe/Warsaw
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y docker-compose nano apache2 samba
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
useradd -M -s /sbin/nologin "samba"
chown -R $USER:www-data /var/www/html
chmod -R 775 /var/www/html
echo "--- Konfiguracja udziału sieciowego ---"
cat <<EOF >> /etc/samba/smb.conf

[www-html]
   path = /var/www/html
   browseable = yes
   read only = no
   guest ok = no
   valid users = samba
   force create mode = 0664
   force directory mode = 0775
   force user = samba
EOF
echo "USTAW HASŁO DLA KONTA SAMBA"
smbpasswd -a "samba"
systemctl restart smbd
systemctl restart nmbd

# Uruchomienie grayloga
cd /graylog
docker-compose up -d

echo "Skrypt zakończony."