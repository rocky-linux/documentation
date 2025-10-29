---
title: Vérification de la Compatibilité CPU
author: Steven Spencer
contributors: Louis Abel, Ganna Zhyrnova
tags:
  - cpu test
---

# Introduction

Certaines installations sur des plateformes x86-64 peuvent échouer en raison d'une « panique du noyau ». Dans la plupart des cas ==cela est dû à une incompatibilité CPU== avec Rocky Linux.

## Test

1. Obtenir une image de démarrage de Rocky Linux 9, Fedora ou autres.

2. Lancer cette image à partir de la machine sur laquelle vous souhaitez installer Rocky Linux 10.

3. Une fois le lancement terminé, ouvrez une fenêtre de terminal et procédez comme suit :

   ```bash
   /lib64/ld-linux-x86-64.so.2 --help | grep x86-64
   ```

   Vous devriez obtenir une sortie similaire à ceci :

   ```bash
   Usage: /lib64/ld-linux-x86-64.so.2 [OPTION]... EXECUTABLE-FILE [ARGS-FOR-PROGRAM...]
   This program interpreter self-identifies as: /lib64/ld-linux-x86-64.so.2
   x86-64-v4
   x86-64-v3 (supported, searched)
   x86-64-v2 (supported, searched)
   ```

   Cette sortie indique la version minimale x86-64 (v3) requise. Dans ce cas, l'installation peut continuer. S'il n'y a pas d'indication `(supported, searched)` à côté de l'entrée `x86-64-v3`, cela signifie que votre processeur n'est **pas** compatible avec Rocky Linux 10. Si le test indique que votre installation peut se poursuivre et qu'il répertorie également `x86-64-v4` comme `(supported, searched)`, votre processeur sera bien pris en charge pour les futures versions de Rocky Linux.
