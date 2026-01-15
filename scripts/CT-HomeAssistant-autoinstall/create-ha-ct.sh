#!/bin/bash

set -e

# ====== Vérifications de base ======
if ! command -v pct >/dev/null 2>&1; then
  echo "❌ Ce script doit être lancé sur un hôte Proxmox VE"
  exit 1
fi

if [ "$EUID" -ne 0 ]; then
  echo "❌ Lance ce script en root"
  exit 1
fi

# ====== Questions utilisateur ======
read -rp "Numéro du CT (ex: 120): " CTID
read -rp "Nom du CT (ex: homeassistant): " HOSTNAME
read -rp "Stockage Proxmox (ex: local-lvm): " STORAGE
read -rp "Taille disque en Go (ex: 32): " DISK
read -rp "Mémoire RAM en Mo (ex: 2048): " RAM
read -rp "Nombre de CPU (ex: 2): " CORES
read -rp "Bridge réseau (ex: vmbr0): " BRIDGE
read -rp "IP (ex: dhcp ou 192.168.10.50/24): " IP
read -rp "Gateway (si IP fixe, sinon laisser vide): " GW

# ====== Template Debian 12 ======
TEMPLATE="debian-12-standard_12.2-1_amd64.tar.zst"
TEMPLATE_PATH="/var/lib/vz/template/cache/$TEMPLATE"

if [ ! -f "$TEMPLATE_PATH" ]; then
  echo "📦 Téléchargement du template Debian 12..."
  pveam update
  pveam download local "$TEMPLATE"
fi

# ====== Réseau ======
if [ "$IP" = "dhcp" ]; then
  NET="name=eth0,bridge=$BRIDGE,ip=dhcp"
else
  NET="name=eth0,bridge=$BRIDGE,ip=$IP,gw=$GW"
fi

# ====== Création CT ======
echo "🚀 Création du CT..."
pct create "$CTID" "$TEMPLATE_PATH" \
  --hostname "$HOSTNAME" \
  --memory "$RAM" \
  --cores "$CORES" \
  --rootfs "$STORAGE:$DISK" \
  --net0 "$NET" \
  --ostype debian \
  --features nesting=1,keyctl=1 \
  --unprivileged 1 \
  --onboot 1

# ====== Démarrage ======
pct start "$CTID"
sleep 10

# ====== Installation Home Assistant ======
echo "🏠 Installation de Home Assistant..."
pct exec "$CTID" -- bash <<'EOF'
set -e

apt update
apt upgrade -y

apt install -y \
  apparmor \
  jq \
  wget \
  curl \
  udisks2 \
  libglib2.0-bin \
  network-manager \
  dbus \
  systemd-journal-remote \
  software-properties-common

curl -fsSL https://get.docker.com | sh
systemctl enable docker
systemctl start docker

curl -fsSL https://raw.githubusercontent.com/home-assistant/supervised-installer/master/installer.sh -o installer.sh
bash installer.sh --machine qemu

EOF

echo "✅ Installation terminée"
echo "🌐 Accès Home Assistant : http://IP_DU_CT:8123"
