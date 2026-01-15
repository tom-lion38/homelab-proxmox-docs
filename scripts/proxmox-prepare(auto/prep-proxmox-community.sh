#!/usr/bin/env bash
set -euo pipefail

# ===== Helpers =====
log() { echo -e "✅ $*"; }
warn() { echo -e "⚠️  $*" >&2; }
die() { echo -e "❌ $*" >&2; exit 1; }

need_root() {
  [ "${EUID:-$(id -u)}" -eq 0 ] || die "Lance ce script en root."
}

need_proxmox() {
  command -v pveversion >/dev/null 2>&1 || die "Proxmox VE non détecté."
  command -v apt-get >/dev/null 2>&1 || die "apt non détecté."
}

backup_file() {
  local f="$1"
  [ -e "$f" ] || return 0
  local ts
  ts="$(date +%Y%m%d-%H%M%S)"
  cp -a "$f" "${f}.bak-${ts}"
  log "Backup: $f -> ${f}.bak-${ts}"
}

confirm() {
  local prompt="${1:-Continuer ?} [o/N] "
  read -r -p "$prompt" ans || true
  case "${ans,,}" in
    o|oui|y|yes) return 0 ;;
    *) return 1 ;;
  esac
}

# ===== Start =====
need_root
need_proxmox

PVEVER="$(pveversion 2>/dev/null | head -n1 || true)"
log "Détecté: ${PVEVER:-Proxmox VE}"

# Detect codename (bookworm for PVE 8, bullseye for PVE 7)
CODENAME="$(. /etc/os-release; echo "${VERSION_CODENAME:-}")"
[ -n "$CODENAME" ] || die "Impossible de détecter VERSION_CODENAME (Debian)."
log "Debian codename: $CODENAME"

echo ""
echo "Ce script va :"
echo " - Désactiver les repos 'enterprise' Proxmox/CEPH (si présents)"
echo " - Activer les repos 'no-subscription' (gratuits) adaptés à ta version"
echo " - Faire update/upgrade complet"
echo " - Installer des paquets de base utiles (outils, réseau, diag, smart, etc.)"
echo " - Nettoyer les paquets inutiles"
echo ""
confirm "Tu confirmes ? [o/N] " || die "Annulé."

# ===== Repo enterprise OFF =====
# Proxmox enterprise
PVE_ENT="/etc/apt/sources.list.d/pve-enterprise.list"
if [ -f "$PVE_ENT" ]; then
  backup_file "$PVE_ENT"
  # Comment out every active 'deb' line
  sed -i -E 's/^\s*deb\s+/# deb /' "$PVE_ENT"
  log "Repo enterprise Proxmox désactivé: $PVE_ENT"
else
  log "Repo enterprise Proxmox: non présent (ok)"
fi

# Ceph enterprise (souvent présent sur certaines installs)
CEPH_ENT="/etc/apt/sources.list.d/ceph.list"
if [ -f "$CEPH_ENT" ]; then
  backup_file "$CEPH_ENT"
  sed -i -E 's/^\s*deb\s+/# deb /' "$CEPH_ENT"
  log "Repo enterprise Ceph désactivé: $CEPH_ENT"
else
  log "Repo enterprise Ceph: non présent (ok)"
fi

# ===== Repo no-subscription ON =====
# Proxmox no-subscription file
PVE_NO="/etc/apt/sources.list.d/pve-no-subscription.list"
backup_file "$PVE_NO"
cat > "$PVE_NO" <<EOF
deb http://download.proxmox.com/debian/pve ${CODENAME} pve-no-subscription
EOF
log "Repo Proxmox no-subscription activé: $PVE_NO"

# Ceph repo community (optionnel mais utile si tu utilises Ceph)
# Proxmox recommande de garder la version Ceph alignée à PVE, mais elle peut être installée plus tard.
# On va le créer commenté, et tu peux l'activer si besoin.
CEPH_COMM="/etc/apt/sources.list.d/ceph-community.list"
backup_file "$CEPH_COMM"
cat > "$CEPH_COMM" <<EOF
# Ceph community repo (active-le seulement si tu utilises Ceph sur ce nœud)
# deb http://download.proxmox.com/debian/ceph-quincy ${CODENAME} no-subscription
EOF
log "Repo Ceph community créé (commenté): $CEPH_COMM"

# ===== Ensure Debian base repos are sane (non intrusif) =====
# On ne remplace pas /etc/apt/sources.list (ça peut être custom). On vérifie juste qu'il existe.
if [ ! -f /etc/apt/sources.list ]; then
  warn "/etc/apt/sources.list absent. Proxmox fonctionne souvent via .list.d, mais c'est inhabituel."
fi

# ===== APT preferences: éviter warning subscription popup =====
# Le popup vient surtout du repo enterprise absent de licence. Ici on l'a désactivé, c'est l'essentiel.

# ===== Update & Upgrade =====
log "APT update…"
apt-get update -y

log "Upgrade (full-upgrade)…"
DEBIAN_FRONTEND=noninteractive apt-get -y full-upgrade

# ===== Base packages =====
# Paquets utiles Proxmox / admin
PKGS=(
  curl wget ca-certificates gnupg lsb-release
  vim nano
  htop iotop iftop
  tmux screen
  unzip zip p7zip-full
  jq
  sudo
  rsync
  git
  net-tools
  dnsutils
  iputils-ping
  traceroute
  mtr-tiny
  tcpdump
  nmap
  ethtool
  bridge-utils
  vlan
  chrony
  smartmontools
  nvme-cli
  lm-sensors
  sysstat
  ncdu
  fail2ban
  openssh-server
  apparmor
)

log "Installation paquets de base…"
DEBIAN_FRONTEND=noninteractive apt-get install -y "${PKGS[@]}"

# ===== Services: chrony & fail2ban =====
log "Activation services utiles…"
systemctl enable --now chrony >/dev/null 2>&1 || true
systemctl enable --now fail2ban >/dev/null 2>&1 || true
systemctl enable --now ssh >/dev/null 2>&1 || true

# ===== Clean =====
log "Nettoyage…"
apt-get autoremove -y
apt-get autoclean -y

# ===== Summary =====
echo ""
log "Terminé."
echo "Résumé :"
echo " - Repo enterprise désactivé (si présent)"
echo " - Repo no-subscription activé : $PVE_NO"
echo " - Mises à jour appliquées + paquets de base installés"
echo ""
echo "Vérif rapide :"
echo "  pveversion"
echo "  apt-cache policy | head -n 30"
echo "  pvesm status"
