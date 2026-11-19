# Retours d'expérience

Les pannes et les pièges qui m'ont appris quelque chose. Je les note pour ne pas
retomber dedans.

## Un seul disque USB pour tout

Au début, presque tous les conteneurs et le NAS étaient sur un seul disque dur USB.
Résultat : lenteurs, erreurs d'entrée/sortie, et Grafana qui plantait sur des
verrous SQLite. Le passage en mode WAL de SQLite a calmé Grafana, mais la vraie
réponse a été de mettre les disques des VM sur du NVMe et les données sur de vrais
disques gérés par ZFS.

**Leçon :** le stockage, c'est la première chose à bien faire.

## « No data » partout dans Grafana

Les graphiques étaient vides depuis mon PC, mais pas depuis le serveur. L'horloge
de mon PC avait pris onze heures de retard : Grafana demandait des données dans le
futur. Une synchro NTP a tout réglé.

**Leçon :** avant de chercher une panne compliquée, vérifier l'heure des deux côtés.

## La carte réseau qui se bloque

La carte intégrée de l'hyperviseur se figeait sous forte charge (message
« Detected Hardware Unit Hang » dans les journaux). Couper les offloads (TSO, GSO,
GRO) a réduit le problème, et le bond actif/secours avec une deuxième carte l'a rendu
invisible.

**Leçon :** une seule carte réseau sur l'hyperviseur, c'est un point de panne.

## Python 3.13 et l'autorité de certification de Proxmox

Après la mise à jour vers Debian 13, un de mes outils refusait le certificat de
Proxmox alors que la CA était bien fournie. Python 3.13 active par défaut la
vérification X.509 stricte, et la CA interne de Proxmox n'a pas l'extension
`keyUsage`. J'ai retiré l'option stricte seulement quand une CA précise est donnée.

## Caddy qui ne recharge plus

Lancer `caddy validate` en root crée le fichier de journal au nom de root. Le service
Caddy, qui tourne avec son propre utilisateur, ne peut plus l'ouvrir et le
rechargement échoue. Il faut valider avec l'utilisateur de Caddy, ou corriger le
propriétaire du fichier après coup.

## RouterOS et les sessions REST

Interroger l'API REST du MikroTik trop souvent finissait par saturer ses sessions.
J'ai regroupé les requêtes et réduit la fréquence dans mes outils.

## Le DNS qui met vingt secondes

Avec Pi-hole arrêté, certaines requêtes (les AAAA en particulier) partaient vers un
serveur qui ne répondait pas, et chaque résolution attendait le délai complet. Le
routeur répond maintenant lui-même pour les noms vitaux, et les conteneurs ont un
délai DNS court (`options timeout:1`).

## Remplacer un conteneur sans tout casser

Pour refaire un vieux CT sur le modèle commun, je crée le nouveau à côté avec la
même adresse et la même MAC, j'arrête l'ancien en coupant sa carte réseau et en le
marquant « ne pas démarrer », puis je ne le supprime qu'après quelques jours sans
problème. Si deux CT avec la même adresse démarrent en même temps, ça se passe mal :
d'où les étiquettes bien visibles dans Proxmox.
