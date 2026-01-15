# 🏠 Home Assistant Supervised sur Proxmox (CT Debian 12)

Script Bash interactif pour créer automatiquement un **CT LXC Debian 12**
et installer **Home Assistant Supervised** sur **Proxmox VE**.

---

## ✨ Fonctionnalités

- Liste automatiquement les **stockages Proxmox disponibles**
- Télécharge le template Debian 12 si absent
- CT LXC **non privilégié**
- Docker + dépendances officielles
- Installation Home Assistant Supervised 100 % automatisée

---

## 📋 Prérequis

- Proxmox VE 7 ou 8
- Accès root
- Connexion internet sur l’hôte

---

## 🚀 Utilisation

```bash
chmod +x create-ha-ct.sh
./create-ha-ct.sh
