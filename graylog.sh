#!/bin/bash

# Pobieranie wszystkich potrzebnych elementów
sudo timedatectl set-timezone UTC+1
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install docker-compose nano
sudo usermod -aG docker $USER

# Utworzenie katalogu graylog
sudo mkdir /graylog
sudo chmod 777 /graylog
echo "Utworzono katalog /graylog z uprawnieniami 777."

# Pobranie pliku docker-compose do folderu /graylog
docker = "https://raw.githubusercontent.com/mateuszkopa/graylogwindows/refs/heads/main/docker-compose.yml"
if [ -n "$docker" ]; then
  cd /graylog
  sudo wget "$docker"
  if [ $? -eq 0 ]; then
    echo "Pobrano plik do /graylog."
  else
    echo "Wystąpił błąd podczas pobierania pliku do /graylog."
  fi
else
  echo "Nie podano linku do pierwszego pliku."
fi

# Przejcie do folderu apache
cd /var/www/html/
echo "Przejście do katalogu /var/www/html/."

# Utworzenie folderów dla plików konfiguracyjnych nxloga
mkdir koncowki
mkdir serwery
echo "Utworzenie folderów koncowki i serwery"

# Pobranie konfiguracji nxloga dla końcówek do /var/www/html/koncowki
cd koncowki
nxlog_koncowki = "https://raw.githubusercontent.com/mateuszkopa/graylogwindows/refs/heads/main/koncowki/nxlog.conf"
if [ -n "$nxlog_koncowki" ]; then
  sudo wget "$nxlog_koncowki"
  if [ $? -eq 0 ]; then
    echo "Pobrano plik do /var/www/html/koncowki."
  else
    echo "Wystąpił błąd podczas pobierania pliku do /var/www/html/koncowki."
  fi
else
  echo "Nie podano linku do konfiguracji nxloga."
fi

# Edycja pliku konfiguracyjnego nxloga dla koncowek
sudo nano nxlog.conf

# Pobranie konfiguracji nxloga dla serwerów do /var/www/html/serwery
cd ..
cd serwery
nxlog_serwery = "https://raw.githubusercontent.com/mateuszkopa/graylogwindows/refs/heads/main/serwery/nxlog.conf"
if [ -n "$nxlog_serwery" ]; then
  sudo wget "$nxlog_serwery"
  if [ $? -eq 0 ]; then
    echo "Pobrano plik do /var/www/html/serwery."
  else
    echo "Wystąpił błąd podczas pobierania pliku do /var/www/html/serwery."
  fi
else
  echo "Nie podano linku do konfiguracji nxloga."
fi

# Edycja pliku konfiguracyjnego nxloga dla serwerow
sudo nano nxlog.conf

echo "Skrypt zakończony."