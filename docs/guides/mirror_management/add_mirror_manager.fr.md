---
title: Ajout d'un Rocky Mirror
contributors: Amin Vakil, Steven Spencer, Ganna Zhyrnova
---

# Ajout d'un miroir public au gestionnaire de miroir de Rocky

## Exigences minimum pour les miroirs publics

Nous accueillons volontiers de nouveaux miroirs publics. Mais ils devraient être entretenus régulièrement et hébergés dans un centre de données 24 h sur 24, 7 jours sur 7. La bande passante disponible doit être d'au moins 1 Gigaoctets/s. Nous préférons les miroirs offrant une double pile (IPv4 et IPv6). Veuillez ne pas proposer de miroirs configurés en utilisant un DNS dynamique. Si vous offrez un miroir dans une région qui n'a que peu de miroirs, nous accepterons aussi des vitesses plus lentes.

Veuillez ne pas soumettre de miroirs qui sont hébergés dans un Anycast-CDN comme Cloudflare, etc., car cela peut conduire à des performances sous-optimales avec la sélection du miroir le plus rapide dans `dnf`.

Veuillez noter que nous ne sommes pas autorisés à accepter les miroirs publics dans les pays soumis à la réglementation des États-Unis en matière d'exportation. Vous pouvez trouver une liste de ces pays ici : [https://www.bis.doc.gov/index.php/policy-guidance/country-guidance/sanctioned-destinations](https://www.bis.doc.gov/index.php/policy-guidance/country-guidance/sanctioned-destinations)

À partir de fin 2022 (date de cet article), l'espace de stockage requis pour accueillir toutes les versions actuelles et anciennes de Rocky Linux est d'environ 2 Téraoctets.

Notre miroir principal est `rsync://msync.rockylinux.org/rocky-linux`. Pour votre première synchronisation, utilisez un miroir près de chez vous. Vous trouverez tous les sites miroirs [ici](https://mirrors.rockylinux.org).

Veuillez noter que nous pourrions restreindre l'accès au miroir principal officiel aux miroirs publics officiels à l'avenir. Alors s'il vous plaît envisagez `de resynchroniser` depuis un miroir public près de chez vous si vous utilisez un miroir privé. La synchronisation à partir de miroirs locaux devrait également être plus efficace.

## Configuration de votre Miroir

Veuillez configurer une tâche cron pour synchroniser votre miroir périodiquement et le laisser tourner environ 6 fois par jour. Mais assurez-vous de synchroniser l'heure avec un délai aléatoire pour aider à répartir la charge au fil du temps. Si vous ne vérifiez que les modifications de `fullfiletimelist-rocky` et faites une synchronisation complète que si ce fichier a changé, vous pouvez synchroniser toutes les heures.

Voici quelques exemples de crontab pour vous :

```bash
#This will synchronize your mirror at 0:50, 4:50, 8:50, 12:50, 16:50, 20:50
50 */6  * * * /path/to/your/rocky-rsync-mirror.sh > /dev/null 2>&1

#This will synchronize your mirror at 2:25, 6:25, 10:25, 14:25, 18:25, 22:25
25 2,6,10,14,18,22 * * * /path/to/your/rocky-rsync-mirror.sh > /dev/null 2>&1

#This will synchronize your mirror every hour at 15 minutes past the hour.
#Only use if you are using our example script
15 * * * * /path/to/your/rocky-rsync-mirror.sh > /dev/null 2>&1
```

Pour une synchronisation simple, vous pouvez utiliser la commande `rsync` suivante :

```bash
rsync -aqH --delete source-mirror destination-dir
```

Envisagez d'utiliser un mécanisme de verrouillage pour éviter d'exécuter plus d'une tâche `rsync` à la fois lorsque nous poussons une nouvelle version.

Vous pouvez également utiliser et modifier notre exemple de script implémentant le verrouillage et la synchronisation complète si nécessaire. Il se trouve sur <https://github.com/rocky-linux/rocky-tools/blob/main/mirror/mirrorsync.sh>.

Après votre première synchronisation complète, vérifiez que tout va bien avec votre miroir. Avant tout, vérifiez que tous les fichiers et répertoires sont synchronisés, que votre tâche cron fonctionne correctement et que votre miroir est accessible depuis Internet publiquement. Vérifiez scrupuleusement les règles de votre pare-feu ! Pour éviter tout problème, n'imposez pas la redirection http vers https.

Si vous avez des questions concernant votre miroir n'hésitez pas à nous joindre sur ce canal : <https://chat.rockylinux.org/rocky-linux/channels/infrastructure>

Lorsque vous avez terminé continuez avec la section suivante et proposez votre miroir pour le rendre public !

## Ce dont vous avez besoin

- Un compte sur <https://accounts.rockylinux.org/>

## Création d'un Site

Rocky utilise 'Fedora's Mirror Manager' pour organiser des miroirs communautaires.

Accédez au gestionnaire de miroir de Rocky Linux ici : <https://mirrors.rockylinux.org/mirrormanager/>

Après une connexion réussie, votre profil apparaîtra en haut à droite. Sélectionnez le menu déroulant puis cliquez sur "My sites".

Une nouvelle page affichera la liste de tous les sites sous les données du compte. La première fois, elle sera vide. Cliquez sur "Enregistrer un nouveau site".

Une nouvelle page chargera avec une importante déclaration de conformité d'exportation. Remplissez ensuite les informations suivantes :

- "Nom du site"
- "Mot de passe du site" - utilisé par le script `report_mirrors`, vous indiquez ce que vous voulez
- "URL de l'organisme" - URL de la société/école/organisation par exemple, <https://rockylinux.org/>
- "Privé" - Cocher cette case permet de masquer votre miroir de l'utilisation publique.
- "Utilisateur actif" - Décochez cette case pour désactiver temporairement le site, il sera supprimé des listes publiques.
- "All sites can pull from me?" - Permet à tous les sites miroirs de faire un pull du site sans les ajouter explicitement à ma liste.
- "Comments for downstream siteadmins. Please include your synchronization source here to avoid dependency loops."

En cliquant sur "Submit", vous serez renvoyé à la page principale du miroir.

## Configuration du Site

À partir de la page principale du miroir, sélectionnez la liste déroulante, puis cliquez sur "Mes sites".

La page du site du compte se chargera et le site devrait être listé. Cliquez dessus pour accéder au site d'information.

Toutes les options de la dernière section sont listées à nouveau. Au bas de la page se trouvent trois nouvelles options : Admins, Hôtes et Supprimer le site. Cliquez sur "Hosts [add]".

## Création d'un nouvel Hôte

Remplissez les options appropriées pour le site comme suit :

- "Host name" - requis : FQDN du serveur vu par un utilisateur public
- "User active" - Décochez cette case pour désactiver temporairement cet hôte, il sera supprimé des listes publiques.
- "Country" - requis : code du pays ISO à 2 lettres
- "Bandwidth" - requis : nombre entier en megabits/sec, combien de bande passante cet hôte peut servir
- "Private" - par exemple non disponible pour le public, un miroir privé interne
- "Internet2" - sur Internet2
- "Internet2 clients " - sert les clients Internet2, même s'ils sont privés
- "ASN" - Autonomous System Number, utilisé dans les tables de routage BGP. Seulement si vous êtes un FAI.
- « Clients ASN » : servir tous les clients du même ASN. Il est utilisé pour les FAI, les entreprises ou les écoles, pas pour les réseaux personnels.
- "Robot email" - adresse e-mail, recevra un avis de mise à jour du contenu amont
- "Commentaire" - texte, tout ce que vous aimeriez qu'un utilisateur public sache sur votre miroir
- "Max connections" - Nombre maximal de connexions de téléchargement parallèles par client, suggéré via les métalinks.

Cliquez sur "Create" et il redirigera vers le site d'information de l'hôte.

## Mise à jour de l'hôte

Au bas du site d'informations, l'option `hosts` devrait désormais afficher le titre de l'hôte juste à côté. Cliquez sur le nom pour charger la page d'hôte. Toutes les mêmes options de l'étape précédente sont listées à nouveau. De nouvelles options apparaissent en bas de page.

- « Site-local Netblocks » : les Netblocks sont utilisés pour tenter de guider l'utilisateur final vers un miroir spécifique au site. Par exemple, une université peut lister ses blocs réseau et le CGI de la liste miroir renverra le miroir local de l'université plutôt qu'un miroir local du pays. Le format peut être 18.0.0.0/255.0.0.0, 18.0.0.0/8, un préfixe/longueur IPv6 ou un nom d'hôte DNS. Les valeurs doivent être des adresses IP publiques (pas d'adresses privées RFC1918). Utiliser uniquement si vous êtes un fournisseur d'accès Internet et/ou que vous possédez un netblock routeable publiquement !

- « Peer ASNs » : les Peer ASNs sont utilisés pour guider un utilisateur final sur des réseaux proches vers notre miroir. Par exemple, une université peut répertorier les ASN de ses pairs, et le CGI de la liste miroir renverra le miroir local de l'université plutôt qu'un miroir local du pays. Vous devez être dans le groupe des administrateurs de `MirrorManager` afin de saisir de nouvelles entrées dans ce contexte.

- « Countries Allowed » : Certains miroirs doivent se limiter à servir uniquement les utilisateurs finaux de leur pays. Si vous en faites partie, listez le code ISO à deux lettres pour les pays dont vous autoriserez les utilisateurs finaux. Le fichier dans `mirrorlist CGI` honorera cela.

- « Categories Carried » : les hôtes transportent des catégories de logiciels. Exemple, `Fedora categories` incluent `Fedora` et `Fedora Archive`.

Cliquez sur le lien `[add]` sous `Categories Carried`.

### Catégories Transposées

Pour la catégorie, sélectionnez `Rocky Linux` puis `Create` pour charger la page URL. Ensuite, cliquez sur `[add]` pour charger la page `Add host category URL`. Il existe une option. Répétez si nécessaire pour chacun des protocoles supportés par les miroirs.

- « URL » - URL (`rsync`, `https`, `http`) pointant vers le répertoire principal

Exemples :

- `http://rocky.example.com`
- `https://rocky.example.com`
- `rsync://rocky.example.com`

## Wrap up

Une fois les informations renseignées, le site devrait apparaître dans la liste des miroirs dès le prochain rafraîchissement de miroirs.
