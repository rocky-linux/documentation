---
title:  'Paketsignering och testning'
---


RPMs som produceras av oss ska vara kryptografiskt signerade med en Rocky Linux nyckel, vilket garanterar för användarna att paketet 
verkligen är byggt av Rocky Linux-projektet.

Paketet måste också gå igenom någon sorts testning - helst automatiserad. Testningens karaktär är ännu inte fastställd, 
men vi vill göra några minst några snabba hälsokontroller innan vi släpper paket ut till världen. (Är detta pake installerbart? Missade vi några filer av misstag? Orsakar det konflikter mellan dnf/yum-beroende? t.ex.)
