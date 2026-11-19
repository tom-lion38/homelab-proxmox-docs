# Sécurité

Les règles que j'applique à tout le lab. Rien d'exotique, mais appliqué partout.

## Accès

- Connexion SSH par clé uniquement, jamais par mot de passe.
- Les interfaces d'administration (Proxmox, PBS, NAS, routeur, mes outils) ne
  répondent que depuis le LAN ou le VPN.
- Une alerte part à chaque connexion root sur l'hôte et à chaque changement des clés
  SSH autorisées.

## Conteneurs

- Non privilégiés par défaut.
- Les applis tournent avec un utilisateur dédié, jamais en root.
- Les services systemd sont durcis (système de fichiers en lecture seule sauf leurs
  données, pas d'élévation de privilèges, liste fermée de ce qu'ils peuvent
  exécuter). `systemd-analyze security` sert de note.
- Mises à jour de sécurité automatiques (unattended-upgrades) dans chaque CT.

## Réseau

- Les sites les plus exposés ont un pare-feu nftables dans leur CT : en entrée,
  seul le reverse proxy peut les joindre ; en sortie, le reste du LAN est bloqué. Un
  site compromis ne peut pas aller fouiller le réseau.
- CrowdSec sur l'hôte et dans le reverse proxy.
- Le moins de redirections de ports possible sur le routeur.

## Applis web

- Dépendances tenues à jour (Next.js et React en particulier, les failles y sont
  sérieuses).
- En-têtes de sécurité, et CSP stricte sur les sites qui ont un espace de connexion.
- Secrets dans des fichiers d'environnement lisibles par le seul service, jamais
  dans le code ni dans git.

## Ce que je ne publie pas

Ce dépôt ne contient aucune adresse, aucun nom de machine ni de domaine, aucun
numéro de conteneur, aucun compte et aucun secret.
