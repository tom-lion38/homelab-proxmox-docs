# Supervision et journaux

## Les métriques

Telegraf collecte les métriques de l'hôte Proxmox, du PBS, du routeur MikroTik, de
l'onduleur et des conteneurs, et les écrit dans InfluxDB 2. Grafana affiche le tout
dans des tableaux de bord générés par script, ce qui permet de les refaire à
l'identique.

J'ai essayé Zabbix et Prometheus avant. Je suis resté sur InfluxDB et Telegraf
parce que les plugins de Telegraf couvrent presque tout mon matériel sans exporter
à installer partout.

## La disponibilité

Uptime Kuma teste régulièrement chaque site et chaque service (HTTP, ping, ports).
C'est lui qui dit « le site est tombé », pas Grafana.

## Les journaux

Toutes les machines envoient leur syslog (rsyslog en envoi seul) vers un CT Loki,
avec Alloy pour la réception. Les journaux sont stockés sur le NAS. Dans Grafana, je
peux chercher dans les journaux de toutes les machines au même endroit, ce qui
change tout quand une panne touche plusieurs services.

## Les alertes

Les alertes arrivent sur mon téléphone avec ntfy, que j'héberge moi-même. Ce qui
déclenche une alerte :

- un site ou un service qui ne répond plus (Uptime Kuma)
- un seuil dépassé (disque, mémoire, température, pool ZFS dégradé) via les
  alertes de Grafana
- une sauvegarde manquante ou trop vieille
- une connexion root sur l'hôte ou une clé SSH ajoutée
- l'onduleur qui passe sur batterie

## L'onduleur

NUT tourne sur l'hôte, l'onduleur est en USB. Quand il passe sur batterie, une
alerte part. S'il reste sur batterie plus de deux minutes, un script arrête d'abord
les machines les moins importantes pour gagner de l'autonomie, puis l'hôte s'éteint
proprement si la batterie arrive au bout. Au retour du courant, le routeur relance
l'hyperviseur par Wake-on-LAN.
