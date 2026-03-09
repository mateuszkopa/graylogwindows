#!/bin/bash

# ==============================================================================
# SKRYPT INSTALACYJNY GRAYLOG + NXLOG + SAMBA + KONFIGURACJA SIECI
# Wersja: 1.1 (Zabezpieczone hasło SHA2-256 + AWK)
# ==============================================================================

# Sprawdzenie czy skrypt jest uruchamiany jako root
if [ "$EUID" -ne 0 ]; then 
  echo "BŁĄD: Uruchom skrypt jako root (używając sudo)."
  exit 1
fi

# Pobieranie wszystkich potrzebnych elementów
echo "[1/10] Aktualizacja systemu i instalacja pakietów..."
timedatectl set-timezone Europe/Warsaw
apt-get update
apt-get upgrade -y
apt-get install -y docker-compose nano apache2 samba python3-venv net-tools awk python-setuptools
usermod -aG docker $USER

# Utworzenie katalogu graylog
echo "[2/10] Konfiguracja katalogu /graylog..."
mkdir -p /graylog
chmod 777 /graylog
echo "Utworzono katalog /graylog z uprawnieniami 777."

# Pobranie pliku docker-compose do folderu /graylog
cd /graylog
wget https://raw.githubusercontent.com/mateuszkopa/graylogwindows/refs/heads/main/docker-compose.yml

# ==============================================================================
# KONFIGURACJA HASŁA GRAYLOG - SHA2-256 (AWK)
# ==============================================================================
echo "[3/10] Konfiguracja hasła root dla Graylog..."
read -s -p "Podaj hasło root dla Graylog: " GRAYLOG_PASSWORD
echo
read -s -p "Potwierdź hasło root dla Graylog: " GRAYLOG_PASSWORD_CONFIRM
echo

if [ "$GRAYLOG_PASSWORD" != "$GRAYLOG_PASSWORD_CONFIRM" ]; then
    echo "BŁĄD: Hasła nie są identyczne!"
    exit 1
fi

if [ -z "$GRAYLOG_PASSWORD" ]; then
    echo "BŁĄD: Hasło nie może być puste!"
    exit 1
fi

# Generowanie hash SHA2-256 (bez znaku nowej linii na końcu hasła)
GRAYLOG_HASH=$(echo -n "$GRAYLOG_PASSWORD" | sha256sum | awk '{print $1}')
echo "✓ Wygenerowano hash SHA2-256 dla hasła."

# Tworzenie kopii zapasowej przed modyfikacją
cp docker-compose.yml docker-compose.yml.bak

# 🔧 Zamiana linii z GRAYLOG_ROOT_PASSWORD_SHA2 przy użyciu AWK
# AWK automatycznie wykrywa i zachowuje oryginalne wcięcie linii
awk -v hash="$GRAYLOG_HASH" '
/GRAYLOG_ROOT_PASSWORD_SHA2:/ {
    # Wykryj wcięcie (spacje/tabulacje na początku linii)
    match($0, /^[[:space:]]*/)
    indent = substr($0, RSTART, RLENGTH)
    # Wypisz linię z zachowanym wcięciem i nowym hashem
    print indent "GRAYLOG_ROOT_PASSWORD_SHA2: \"" hash "\""
    next
}
# Wszystkie inne linie wypisz bez zmian
{ print }
' docker-compose.yml.bak > docker-compose.yml.tmp

# Atomowa zamiana pliku (bezpieczna operacja)
mv docker-compose.yml.tmp docker-compose.yml

# Weryfikacja czy zamiana się powiodła
if grep -q "GRAYLOG_ROOT_PASSWORD_SHA2: \"${GRAYLOG_HASH}\"" docker-compose.yml; then
    echo "✓ Pomyślnie zaktualizowano GRAYLOG_ROOT_PASSWORD_SHA2 w pliku docker-compose.yml"
else
    echo "⚠️  Ostrzeżenie: Nie znaleziono klucza GRAYLOG_ROOT_PASSWORD_SHA2 w pliku!"
    echo "   Sprawdź ręcznie plik: nano docker-compose.yml"
    echo "   Przywracanie kopii zapasowej..."
    mv docker-compose.yml.bak docker-compose.yml
    exit 1
fi

# Wyczyszczenie zmiennych z hasłem z pamięci
unset GRAYLOG_PASSWORD
unset GRAYLOG_PASSWORD_CONFIRM

# Opcjonalna weryfikacja
read -p "Czy chcesz zobaczyć zmodyfikowaną linię? (T/N): " show_answer
if [ "$show_answer" == "T" ] || [ "$show_answer" == "t" ]; then
    grep "GRAYLOG_ROOT_PASSWORD_SHA2" docker-compose.yml
fi

read -p "Czy chcesz ręcznie edytować plik docker-compose.yml? (T/N): " edit_answer
if [ "$edit_answer" == "T" ] || [ "$edit_answer" == "t" ]; then
    nano docker-compose.yml
fi
# ==============================================================================

# Przejście do folderu apache
echo "[4/10] Konfiguracja Apache..."
chmod 777 /var/www/html/
cd /var/www/html/
echo "Przejście do katalogu /var/www/html/."
rm -f index.html

# Utworzenie folderów dla plików konfiguracyjnych nxloga
echo "[5/10] Przygotowanie folderów dla NXLog..."
mkdir -p install koncowki serwery
chmod 777 install koncowki serwery
echo "Utworzenie folderów koncowki i serwery"

# Pobranie konfiguracji nxloga dla końcówek do /var/www/html/koncowki
echo "[6/10] Pobieranie plików NXLog..."
cd install
wget https://raw.githubusercontent.com/mateuszkopa/graylogwindows/refs/heads/main/nxlog.msi  
wget https://raw.githubusercontent.com/mateuszkopa/graylogwindows/refs/heads/main/Sysmon64.exe  
wget https://raw.githubusercontent.com/olafhartong/sysmon-modular/master/sysmonconfig.xml  
cd ..
cd koncowki
wget https://raw.githubusercontent.com/mateuszkopa/graylogwindows/refs/heads/main/koncowki/nxlog.conf  

# Edycja pliku konfiguracyjnego nxloga dla koncowek
echo "Edycja pliku konfiguracyjnego nxloga dla końcówek..."
nano nxlog.conf

# Pobranie konfiguracji nxloga dla serwerów do /var/www/html/serwery
cd ..
cd serwery
wget https://raw.githubusercontent.com/mateuszkopa/graylogwindows/refs/heads/main/serwery/nxlog.conf  

# Edycja pliku konfiguracyjnego nxloga dla serwerow
echo "Edycja pliku konfiguracyjnego nxloga dla serwerów..."
nano nxlog.conf

# SAMBA
echo "[7/10] Konfiguracja SAMBA..."
cd /var/www/html/
wget https://raw.githubusercontent.com/mateuszkopa/graylogwindows/refs/heads/main/samba.sh  
chmod 777 samba.sh
./samba.sh
wait

# Uruchomienie grayloga
echo "[8/10] Uruchamianie Graylog..."
cd /graylog
docker-compose up -d

# Zmiana adresów IP
echo "[9/10] Konfiguracja sieci..."
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

echo "[10/10] Skrypt zakończony."
# Opcjonalne usunięcie skryptu po wykonaniu (odkomentuj jeśli chcesz)
# rm -- "$0" 