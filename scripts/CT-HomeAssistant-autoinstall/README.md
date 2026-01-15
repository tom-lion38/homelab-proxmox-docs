# 🏠 Home Assistant Supervised sur Proxmox (CT Debian 12)

Script Bash automatisé pour créer un **CT LXC Debian 12** sur **Proxmox VE**
et installer **Home Assistant Supervised** sans prise de tête.

---

## ✨ Fonctionnalités

- Télécharge automatiquement le template Debian 12
- Crée un CT LXC **non privilégié**
- Active `nesting` et `keyctl`
- Installe Docker + dépendances officielles
- Installe Home Assistant Supervised
- 100 % automatisé, interactif et reproductible

---

## 📋 Prérequis

- Proxmox VE 7 ou 8
- Accès root
- Stockage Proxmox fonctionnel
- Connexion internet sur l’hôte

---

## 🚀 Installation

```bash
chmod +x create-ha-ct.sh
./create-ha-ct.sh
