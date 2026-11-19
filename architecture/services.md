# Services

## Infrastructure

| Service | Où | Rôle |
| :-- | :-- | :-- |
| Caddy | CT non privilégié | Reverse proxy de tous les sites, HTTPS automatique, module CrowdSec |
| Pi-hole + unbound | CT | DNS du lab, blocage de pubs, autorité sur `.lan` |
| Supervision | CT | Grafana, InfluxDB 2, Telegraf, Uptime Kuma, ntfy pour les alertes |
| Journaux | CT | Loki et Alloy, reçoit le syslog de toutes les machines |
| Statistiques web | CT | GoAccess, alimenté par les journaux de Caddy |
| Forge git | CT | Forgejo, pour mes dépôts privés et la doc du lab |
| Onduleur | hôte + CT | NUT sur l'hôte, une page de suivi dans un CT |
| Phare | CT | Mon interface de gestion des sites |
| Abysse | CT | Ma carte 3D du lab en direct |

## Stockage et médias

Le NAS est une VM TrueNAS SCALE. Les trois disques de 8 To lui sont donnés
directement (passthrough), Proxmox ne les touche pas. TrueNAS gère le pool ZFS, les
partages SMB et NFS, et fait tourner Jellyfin pour les films et séries.

## Sites web

Chaque site a son propre CT, avec trois modèles :

- statique : nginx
- Node.js : un service systemd qui lance l'appli
- Next.js : pareil, avec un build fait par un utilisateur séparé

Le proxy envoie chaque nom de domaine vers le bon CT. Ajouter un site, c'est créer
le CT à partir d'un préréglage, le déployer, puis ajouter un bloc dans Caddy. Je
fais tout ça depuis [Phare](https://github.com/tom-lion38/phare).

## Le reste

- une VM FreePBX pour la téléphonie, avec des postes en WebRTC et une appli de
  téléphone que j'ai codée
- un serveur RustDesk pour la prise en main à distance
- un serveur TeamSpeak
- une VM Windows Server pour le lab AD, GPO et WDS
- des VM de test qui ne démarrent pas automatiquement
