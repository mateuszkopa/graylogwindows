#!/bin/bash

# Pobieranie wszystkich potrzebnych elementów
sudo timedatectl set-timezone Europe/Warsaw
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install docker-compose nano apache2 python
sudo usermod -aG docker $USER

# Utworzenie katalogu graylog
sudo mkdir /graylog
sudo chmod 777 /graylog
echo "Utworzono katalog /graylog z uprawnieniami 777."

# Pobranie pliku docker-compose do folderu /graylog
cd /graylog
sudo wget https://raw.githubusercontent.com/mateuszkopa/graylogwindows/refs/heads/main/docker-compose.yml 
nano docker-compose.yml

# Stworzenie agentów
mkdir exe
cd exe
pip install pyinstaller
wget https://raw.githubusercontent.com/mateuszkopa/graylogwindows/refs/heads/main/main.py
chmod 777 main.py
python main.py
chmod 777 koncowki.py
chmod 777 serwery.py
pyinstaller --onefile "koncowki.py"
pyinstaller --onefile "serwery.py"
touch License.rtf
mkdir staging staging/resources
cp koncowki.exe staging
cp serwery.exe staging
cd staging/resources/

# Przejcie do folderu apache
chmod 777 /var/www/html/
cd /var/www/html/
echo "Przejście do katalogu /var/www/html/."
rm index.html
wget https://raw.githubusercontent.com/mateuszkopa/graylogwindows/refs/heads/main/nxlog.msi

# Utworzenie folderów dla plików konfiguracyjnych nxloga
mkdir koncowki
chmod 777 koncowki
mkdir serwery
chmod 777 serwery
echo "Utworzenie folderów koncowki i serwery"

# Pobranie konfiguracji nxloga dla końcówek do /var/www/html/koncowki
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

# Uruchomienie grayloga
cd /graylog
docker-compose up -d

echo "Skrypt zakończony."