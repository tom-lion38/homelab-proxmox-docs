#!/bin/bash
set -e

# ====== Vérifications ======
if ! command -v pct >/dev/null 2>&1 || ! command -v pvesm >/dev/null 2>&1; then
  echo "❌ Ce script doit être lancé sur un hôte Proxmox VE"
  exit 1
fi

if [ "$EUID" -ne 0 ]; then
  echo "❌ Lance ce script en root"
  exit 1
fi

# ====== Infos CT ======
read -rp "Numéro du CT (ex: 120): " CTID
read -rp "Nom du CT (hostname): " HOSTNAME
read -rp "RAM en Mo (ex: 2048): " RAM
read -rp "Nombre de CPU (ex: 2): " CORES
read -rp "Taille du disque en Go (ex: 32): " DISK

# ====== Liste stockages ======
echo ""
echo "📦 Stockages disponibles :"
mapfile -t STORAGES < <(pvesm status | awk 'NR>1 {print $1}')

select STORAGE in "${STORAGES[@]}"; do
  if [ -n "$STORAGE" ]; then
    break
  fi
done

# ====== Réseau ======
read -rp "Bridge réseau (ex: vmbr0): " BRIDGE
read -rp "IP (dhcp ou IP/CIDR ex: 192.168.1.50/24): " IP
if [ "$IP" != "dhcp" ]; then
  read -rp "Gateway: " GW
fi

# ====== Template Debian 12 ======
TEMPLATE="debian-12-standard_12.2-1_amd64.tar.zst"
TEMPLATE_PATH="/var/lib/vz/template/cache/$TEMPLATE"

if [ ! -f "$TEMPLATE_PATH" ]; then
  echo "📥 Téléchargement du template Debian 12..."
  pveam update
  pveam download local "$TEMPLATE"
fi

# ====== Réseau config ======
if [ "$IP" = "dhcp" ]; then
  NET="name=eth0,bridge=$BRIDGE,ip=dhcp"
else
  NET="name=eth0,bridge=$BRIDGE,ip=$IP,gw=$GW"
fi

# ====== Création du CT ======
echo "🚀 Création du CT $CTID..."
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

pct start "$CTID"
sleep 10

# ====== Installation Home Assistant ======
echo "🏠 Installation de Home Assistant Supervised..."
pct exec "$CTID" -- bash <<'EOF'
set -e

apt update && apt upgrade -y

apt install -y \
  apparmor \
  jq \
  curl \
  wget \
  udisks2 \
  libglib2.0-bin \
  network-manager \
  dbus \
  software-properties-common

curl -fsSL https://get.docker.com | sh
systemctl enable docker
systemctl start docker

curl -fsSL https://raw.githubusercontent.com/home-assistant/supervised-installer/master/installer.sh -o installer.sh
bash installer.sh --machine qemu
EOF

echo ""
echo "✅ Home Assistant installé"
echo "🌐 Accès : http://IP_DU_CT:8123 (attendre 5–10 min)"
