#!/bin/bash

# Konfiguracja - możesz zmienić nazwę użytkownika tutaj
SAMBA_USER="samba"
SHARE_PATH="/var/www/html"

# Sprawdzenie uprawnień roota
if [[ $EUID -ne 0 ]]; then
   echo "Ten skrypt musi być uruchomiony z uprawnieniami sudo!"
   exit 1
fi

echo "--- Instalacja Samby ---"
apt update && apt install -y samba

# 1. Tworzenie użytkownika systemowego (bez możliwości logowania SSH/GUI)
if id "$SAMBA_USER" &>/dev/null; then
    echo "Użytkownik $SAMBA_USER już istnieje."
else
    echo "Tworzenie użytkownika systemowego $SAMBA_USER..."
    useradd -M -s /sbin/nologin "$SAMBA_USER"
fi

# 2. Ustawianie uprawnień do folderu
mkdir -p "$SHARE_PATH"
# Dodajemy użytkownika do grupy www-data, aby mógł edytować pliki serwera www
usermod -aG www-data "$SAMBA_USER"
chown -R "$SAMBA_USER":www-data "$SHARE_PATH"
chmod -R 775 "$SHARE_PATH"

# 3. Dodanie konfiguracji do /etc/samba/smb.conf
# Najpierw sprawdzamy, czy sekcja już nie istnieje, żeby nie dublować
if grep -q "\[www-html\]" /etc/samba/smb.conf; then
    echo "Konfiguracja [www-html] już istnieje w smb.conf. Pomijam dopisywanie."
else
    echo "Dodawanie konfiguracji do smb.conf..."
    cat <<EOF >> /etc/samba/smb.conf

[www-html]
   comment = Udział WWW
   path = $SHARE_PATH
   browseable = yes
   read only = no
   guest ok = no
   valid users = $SAMBA_USER
   force create mode = 0664
   force directory mode = 0775
   force user = $SAMBA_USER
   force group = www-data
EOF
fi

# 4. Ustawienie hasła Samby
echo "---------------------------------------------------------"
echo "USTAW HASŁO DLA UŻYTKOWNIKA SAMBA: $SAMBA_USER"
echo "To hasło będzie wpisywane przy mapowaniu dysku w Windows."
echo "---------------------------------------------------------"
smbpasswd -a "$SAMBA_USER"

# 5. Restart usług i firewall
systemctl restart smbd
systemctl restart nmbd

if command -v ufw > /dev/null; then
    ufw allow samba
fi

echo "--- Konfiguracja zakończona! ---"
echo "Użytkownik: $SAMBA_USER"
echo "Ścieżka: $SHARE_PATH"