# Réseau

## Le routeur

La box du FAI envoie tout au routeur MikroTik, mis en DMZ. C'est un double NAT,
mais toutes les redirections de ports et toutes les règles de pare-feu du lab sont
au même endroit, sur le MikroTik.

Le MikroTik s'occupe de :

- pare-feu et NAT, avec le moins de redirections possible
- DHCP du lab, avec des baux réservés pour les machines importantes
- VPN WireGuard et OpenVPN pour accéder au lab de l'extérieur
- DNS de secours (voir plus bas)

Avant ce routeur, j'avais des switchs Cisco (Catalyst) et un Netgear avec des
VLAN. Le passage au MikroTik a beaucoup simplifié le lab, et le routage et le
pare-feu sont maintenant au même endroit.

## Le plan d'adressage

Un seul réseau en /24, découpé en blocs par usage : équipements réseau,
hyperviseur et sauvegarde, infrastructure (proxy, DNS, supervision, journaux,
forge), sites web, applis perso, DHCP pour les PC et les appareils, et le routeur.
Une nouvelle machine prend l'adresse suivante dans le bloc de sa famille, jamais
une adresse libre au hasard.

Avec ça, rien qu'en voyant une adresse, je sais à quoi sert la machine. Les plages
exactes restent dans ma doc privée.

## Les noms

Chaque machine a un nom en `.lan`. Pi-hole fait autorité sur `.lan` et fait la
résolution récursive lui-même avec unbound, en plus de bloquer les pubs.

Le problème d'un DNS dans un conteneur, c'est que s'il tombe, plus rien ne résout.
Donc le routeur garde en dur les quelques noms vitaux (lui-même, l'hyperviseur, le
NAS, la sauvegarde, Pi-hole) et renvoie tout le reste à Pi-hole. Si Pi-hole est
arrêté, je peux encore joindre et réparer l'essentiel.

## L'hyperviseur

La carte réseau intégrée de la machine se bloquait de temps en temps (un problème
connu de ce modèle de puce Intel sous Linux). J'ai coupé les offloads de cette
carte et mis l'hyperviseur sur un bond actif/secours : une carte PCIe en lien
principal, la carte intégrée en secours, avec une surveillance ARP vers le routeur.
Si le lien principal tombe, la bascule est automatique.

Un deuxième pont, sans adresse IP et sans passerelle, sert de réseau isolé pour les
essais de déploiement par PXE (voir mon
[lab Windows Server](https://github.com/tom-lion38/windows-server-lab)).

## Ce qui est exposé

Seul le reverse proxy reçoit le trafic web venant d'internet. Les sites eux-mêmes
n'acceptent des connexions que depuis le proxy. Tout ce qui est administration
reste derrière le VPN.
