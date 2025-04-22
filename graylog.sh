#!/bin/bash

# Pobieranie wszystkich potrzebnych elementów
sudo timedatectl set-timezone Europe/Warsaw
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install docker-compose nano
sudo usermod -aG docker $USER

# Utworzenie katalogu graylog
sudo mkdir /graylog
sudo chmod 777 /graylog
echo "Utworzono katalog /graylog z uprawnieniami 777."

# Pobranie pliku docker-compose do folderu /graylog
cd /graylog
  sudo wget https://raw.githubusercontent.com/mateuszkopa/graylogwindows/refs/heads/main/docker-compose.yml  

# Przejcie do folderu apache
cd /var/www/html/
echo "Przejście do katalogu /var/www/html/."

# Utworzenie folderów dla plików konfiguracyjnych nxloga
mkdir koncowki
mkdir serwery
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

echo "Skrypt zakończony."