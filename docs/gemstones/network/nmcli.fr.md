---
title: nmcli - définir la connexion automatique
author: wale soyinka
tags:
  - nmcli
---

# Modifier la propriété 'autoconnect' du profil de connexion de NetworkManager

Utilisez d'abord `nmcli` pour lire et afficher la valeur actuelle de la propriété de connexion automatique pour toutes les connexions réseau sur un système Rocky Linux. Entrer la commande suivante :

```bash
nmcli -f name,autoconnect connection 
```

Pour modifier la valeur d'une propriété pour une connexion réseau, utilisez la sous-commande `modify` avec la `connexion nmcli`. Par exemple, pour changer la valeur de la propriété de connexion automatique de `no` à `yes` pour le profil de connexion `ens3`, tapez :

```bash
sudo nmcli con mod ens3 connection.autoconnect yes
```

## Explication des Commandes

```bash
connection (con) : objet de connexion de NetworkManager. 
modify (mod) : Modifie une ou plusieurs propriétés d'un profil de connexion donné.
connection.autoconnect : le paramètre et la propriété (<setting>.<property>)
-f, --fields : indique les champs à afficher.
```

## Notes

Cette astuce montre comment modifier un profil de connexion de NetworkManager existant. Ceci est utile lorsque l'interface réseau ne sera pas automatiquement activé après une nouvelle installation de Rocky Linux ou une mise à jour du système. La raison de cela est souvent parce que la valeur de la propriété de connexion automatique est définie à `no`. Vous pouvez utiliser la commande `nmcli` pour rapidement changer la valeur à `yes`.  
