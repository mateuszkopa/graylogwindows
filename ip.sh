#!/bin/bash
read -p "Podaj adres IP (np. 192.168.1.100): " IP_ADDR
read -p "Podaj maskę (np. 24 dla 255.255.255.0): " MASK
read -p "Podaj bramę (Gateway): " GW_ADDR
read -p "Podaj DNSy (oddzielone przecinkiem, np. 8.8.8.8, 1.1.1.1): " DNS_ADDR

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

chmod 600 $NETPLAN_FILE

echo "Testowanie konfiguracji (masz 2 sekundy)..."
netplan try --timeout 2
