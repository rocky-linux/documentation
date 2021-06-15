---
title:  'Rocky paket Hur man tar bort varumärke'
---

Detta förklarar hur du ändrar varumärke på ett paket för Rocky Linux-distributionen.


Generella instruktioner

Först, identifiera filerna i paketet som behöver ändras. Dessa kan vara textfiler, bildfiler, eller annat. Du kan identifiera dessa filer/filer genom att kolla i git.centos.org/rpms/PACKAGE/

Utveckla ersättningar för dessa filer, men med Rocky varumärken på plats istället. Diff/patch filer kan också behövas för vissa typer av text, beroende på innehållet som ersätts.

Ersättningsfiler ska places på https://git.rockylinux.org/patch/PACKAGE/ROCKY/_supporting/
Konfigurationsfiler (som speciferar hur du applicerar patches) ska placeras på https://git.rockylinux.org/patch/PACKAGE/ROCKY/CFG/*.cfg

Notera: Använd mellanslag, inte tabbar.
När srpmproc börja importera paketet till Rocky, så kommer det att se arbetet gjort i https://git.rockylinux.org/patch/PACKAGE , och applicera dom lagrade patcharna för att ta bort varumärken genom att läsa konfigurationsfiler under ROCKY/CFG/*.cfg


från https://wiki.rockylinux.org/en/team/development/debranding/how-to


