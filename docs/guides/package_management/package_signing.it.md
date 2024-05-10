---
title: Firma del pacchetto & Testing
---

# Firma e testing dei pacchetti

Gli RPM prodotti da noi dovrebbero essere firmati crittograficamente con una chiave di Rocky Linux, che garantisce agli utenti che il pacchetto è stato compilato dal progetto Rocky Linux.

Il pacchetto dovrà anche essere sottoposto ad alcuni test - preferibilmente automatizzati. La natura dei test deve ancora essere determinata, ma vorremo fare almeno qualche controllo di correttezza prima di rilasciarlo nel mondo. (Questo pacchetto è installabile? Abbiamo perso accidentalmente dei file? Causa conflitti di dipendenze in dnf/yum? etc.)
