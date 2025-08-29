---
title: https — Génération de clé RSA
author: Steven Spencer
update: 2022-01-26
---

# https – Génération de clé RSA

Ce script a été utilisé par l'auteur à plusieurs reprises. Peu importe la fréquence d'utilisation de la structure de commande `openssl`, vous devez parfois vous référer à la procédure. Ce script vous permet d'automatiser la génération de clés pour un site web en utilisant RSA. Notez que ce script est codé en dur avec une longueur de clé de 2048 bits. Pour ceux d'entre vous qui estiment que la longueur minimale de la clé doit être de 4096 bits, il suffit de changer la partie du script concernée. Sachez simplement que vous devez peser la mémoire et la vitesse qu'un site a besoin de charger sur un appareil, contre la sécurité de la longueur de clé plus longue.

## Script

Nommez ce script comme bon vous semble, par exemple : `keygen. h`, rendre le script exécutable (`chmod +x scriptname`) et le placer dans un répertoire qui se trouve dans votre chemin, exemple: /usr/local/sbin

```bash
#!/bin/bash
if [ $1 ]
then
      echo "generating 2048 bit key - you'll need to enter a pass phrase and verify it"
      openssl genrsa -des3 -out $1.key.pass 2048
      echo "now we will create a pass-phrase less key for actual use, but you will need to enter your pass phrase a third time"
      openssl rsa -in $1.key.pass -out $1.key
      echo "next, we will generate the csr"
      openssl req -new -key $1.key -out $1.csr
      #cleanup
      rm -f $1.key.pass
else
      echo "requires keyname parameter"
      exit
fi
```

!!! note "Remarque"

    Vous entrerez la phrase de passe par trois fois.

## Brève Description

* Ce script bash nécessite la saisie d'un paramètre ($1) qui est le nom du site sans aucun www, etc. Par exemple, "mywidget".
* Le script crée la clé par défaut avec un mot de passe et une longueur de 2048 bits (qui peut être modifiée, comme indiqué ci-dessus, en une longueur de 4096 bits)
* Le mot de passe est alors immédiatement supprimé de la clé, la raison est que le redémarrage du serveur web nécessiterait que le mot de passe de la clé soit entré à chaque fois ainsi qu'au redémarrage, ce qui peut être problématique dans la pratique.
* Ensuite, le script crée la CSR (Certificate Signing Request), qui peut ensuite être utilisée pour acheter un certificat SSL auprès d'un fournisseur.
* Enfin, l'étape de nettoyage supprime la clé précédemment créée avec le mot de passe correspondant.
* La saisie du nom du script sans le paramètre génère l'erreur: "Requiert le paramètre keyname".
* La variable de paramètre positionnel, c'est-à-dire $n, est utilisée ici. I.e., $0 représente la commande elle-même et $1 à $9 représente le premier jusqu'au neuvième paramètres. Lorsque le nombre est supérieur à 9, vous devez utiliser des accolades, par exemple ${10}.
