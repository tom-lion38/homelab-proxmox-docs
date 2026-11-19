# Sauvegardes

## Le principe

Une sauvegarde qu'on n'a jamais restaurée n'est pas une sauvegarde. Donc il y a les
sauvegardes, et il y a les contrôles des sauvegardes.

## Ce qui est sauvegardé

| Quoi | Où | Quand |
| :-- | :-- | :-- |
| Tous les CT et VM utiles | Proxmox Backup Server | chaque nuit |
| La configuration de l'hôte Proxmox | Proxmox Backup Server | chaque nuit |
| Les données du NAS | Proxmox Backup Server, par un partage NFS | chaque semaine |
| La configuration du routeur | export chiffré | régulièrement |

Le PBS est une machine physique séparée. Le datastore est rangé en espaces de noms
(infra, sites, archives) avec des rétentions différentes selon l'importance.

## Les contrôles

- **Santé des sauvegardes** : un script vérifie chaque matin que chaque machine a
  une sauvegarde de moins de 24 h, et envoie une alerte sinon.
- **Test de restauration** : une fois par mois, un script restaure automatiquement
  un CT sur un numéro libre, sans réseau, vérifie qu'il démarre, puis le supprime.
- **Kit de reprise** : chaque nuit, un script rassemble ce qu'il faut pour
  reconstruire l'hôte (configuration réseau, stockages, tâches, clés publiques) et
  le met à l'abri hors de l'hôte. Une fiche papier explique quoi faire si
  l'hyperviseur meurt.

Ces scripts, en version générique, sont dans
[proxmox-scripts](https://github.com/tom-lion38/proxmox-scripts).

## Avant chaque changement

Instantané du CT ou de la VM, puis le changement, puis contrôle. Pour les
changements risqués sur un service en ligne, je prépare tout à côté et je pose un
filet : une tâche qui remet l'ancienne version toute seule au bout de quelques
minutes si je ne l'annule pas après avoir vérifié que tout marche.
