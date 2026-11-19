# homelab-proxmox-docs

La doc de mon homelab, en version publique. J'ai retiré tout ce qui permettrait de
retrouver mon réseau : pas d'adresses, pas de noms de machines, pas de domaines,
pas de numéros de conteneurs. Ce qui reste, c'est comment c'est organisé et
pourquoi.

## En bref

Un serveur Proxmox VE fait tout tourner : une trentaine de conteneurs LXC et
quelques VM. Un Proxmox Backup Server sur une autre machine sauvegarde tout chaque
nuit. Le réseau passe par un routeur MikroTik, et un onduleur protège le tout.

## Sommaire

- [Vue d'ensemble et matériel](architecture/README.md)
- [Réseau](architecture/reseau.md) : routeur, plan d'adressage, DNS, VPN
- [Services](architecture/services.md) : ce qui tourne et comment c'est découpé
- [Sauvegardes](architecture/sauvegardes.md) : PBS, NAS, tests de restauration
- [Supervision et journaux](architecture/supervision.md) : Grafana, Uptime Kuma, Loki, alertes
- [Sécurité](architecture/securite.md) : les règles que j'applique partout
- [Retours d'expérience](notes/retours-experience.md) : les pannes et pièges qui m'ont appris quelque chose

## Les outils que j'ai écrits pour le lab

- [proxmox-scripts](https://github.com/tom-lion38/proxmox-scripts) : post-installation, création de CT, sauvegardes, alertes
- [phare](https://github.com/tom-lion38/phare) : une interface web pour gérer les sites (allumer, éteindre, brancher dans Caddy, déployer)
- [abysse](https://github.com/tom-lion38/abysse) : une carte 3D du homelab qui bouge en direct

## Comment je documente

Chaque intervention sur le lab finit par une entrée datée dans un journal, dans un
dépôt git privé hébergé sur le lab. Un script régénère chaque nuit l'état réel
(liste des machines, sauvegardes, noms DNS), ce qui permet de comparer la doc et la
réalité. Ce dépôt-ci en est la version nettoyée.
