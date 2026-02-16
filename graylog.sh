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
read -p "Podaj adres IP (np. 192.168.1.100): " IP_ADDR
read -p "Podaj maskę (np. 24 dla 255.255.255.0): " MASK
read -p "Podaj bramę (Gateway): " GW_ADDR
read -p "Podaj DNSy (oddzielone przecinkiem, np. 8.8.8.8, 1.1.1.1): " DNS_ADDR

# Sprawdzenie czy zmienne nie są puste
if [[ -z "$IP_ADDR" || -z "$MASK" || -z "$GW_ADDR" || -z "$DNS_ADDR" ]]; then
    echo "BŁĄD: Wszystkie pola muszą być wypełnione!"
    exit 1
fi

mkdir -p /etc/netplan/backup_old
mv /etc/netplan/*.yaml /etc/netplan/backup_old/ 2>/dev/null

NETPLAN_FILE="/etc/netplan/01-netcfg.yaml"

echo "Generowanie konfiguracji w $NETPLAN_FILE..."

# Tworzenie pliku Netplan (zwróć uwagę na formatowanie YAML)
cat <<EOF > $NETPLAN_FILE
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - $IP_ADDR/$MASK
      routes:
        - to: default
          via: $GW_ADDR
      nameservers:
        addresses: [$DNS_ADDR]
EOF

# Zabezpieczenie pliku
chmod 600 $NETPLAN_FILE

# Testowanie i stosowanie
echo "Testowanie konfiguracji (masz 2 sekundy)..."
netplan try --timeout 2

if [ $? -eq 0 ]; then
    echo "Zastosowano zmiany pomyślnie."
else
    echo "Wystąpił problem z konfiguracją. Sprawdź plik YAML."
fi
fi

echo "Skrypt zakończony."