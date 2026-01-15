# ⚙️ Proxmox VE — Préparation “Community” (repos gratuits + base tools)

Ce dépôt fournit un script Bash qui prépare un nœud **Proxmox VE** :
- désactive les dépôts **enterprise** (payants) s’ils sont présents
- active le dépôt **pve-no-subscription** (gratuit)
- applique toutes les updates
- installe un set de paquets “essentiels” pour l’admin, le réseau et le diagnostic

---

## ✅ Ce que fait le script

1. **Détecte Proxmox VE** + le codename Debian (`bookworm`, `bullseye`, etc.)
2. **Désactive** :
   - `/etc/apt/sources.list.d/pve-enterprise.list` (si présent)
   - `/etc/apt/sources.list.d/ceph.list` (si présent)
3. **Active** le repo gratuit :
   - `/etc/apt/sources.list.d/pve-no-subscription.list`
4. Lance :
   - `apt update`
   - `apt full-upgrade`
5. Installe des paquets utiles :
   - outils système : `htop`, `iotop`, `sysstat`, `ncdu`, `lm-sensors`
   - réseau : `tcpdump`, `nmap`, `dnsutils`, `mtr`, `ethtool`, `vlan`, etc.
   - stockage : `smartmontools`, `nvme-cli`
   - sécurité : `fail2ban`, `apparmor`
6. Active des services utiles :
   - `chrony`, `fail2ban`, `ssh`
7. Nettoie :
   - `autoremove`, `autoclean`

---

## 📋 Prérequis

- Proxmox VE 7/8
- Accès root
- Connexion internet
- Un minimum de bon sens (c’est un script “système”)

---

## 🚀 Utilisation

```bash
chmod +x prep-proxmox-community.sh
sudo ./prep-proxmox-community.sh
