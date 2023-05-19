---
title: Gerenciamento de usuários
---

# Gerenciamento de usuários

Neste capítulo você aprenderá como gerenciar usuários.

****
**Objetivos**: Neste capítulo, os futuros administradores do Linux aprenderão como:

:heavy_check_mark: adicionar, excluir ou modificar um **grupo**;   
:heavy_check_mark: adicionar, excluir ou modificar um **usuário**;   
:heavy_check_mark: entender os arquivos associados a usuários e grupos e aprender a gerenciá-los;   
:heavy_check_mark: alterar o *proprietário* ou o *grupo proprietário* de um arquivo;   
:heavy_check_mark: *proteger* as contas de usuário;   
:heavy_check_mark: mudar a identidade.

:checkered_flag: **usuários**

**Conhecimento**: :star: :star:   
**Complexidade**: :star: :star:

**Tempo de leitura**: 30 minutos
****

## Geral

Cada usuário deve ter um grupo, que é chamado de **grupo primário** do usuário.

Vários usuários podem fazer parte do mesmo grupo.

Grupos diferentes do grupo primário são chamados de **grupos complementares** do usuário.

!!! Nota

    Cada usuário tem um grupo primário e pode ser convidado para um ou mais grupos complementares.

Grupos e usuários são gerenciados por seus identificadores numéricos exclusivos `GID` e `UID`.

* `UID`: _IDentificador do Usuário_. ID Único de usuário.
* `GID`: _IDentidficador do Grupo_. Identificador exclusivo do grupo.

Tanto o UID quanto o GID são reconhecidos pelo kernel, o que significa que o Super Admin não é necessariamente o usuário **root**, contanto que o usuário **uid=0** seja o Super Admin.

Os arquivos relacionados aos usuários/grupos são:

* /etc/passwd
* /etc/shadow
* /etc/group
* /etc/gshadow
* /etc/skel/
* /etc/default/useradd
* /etc/login.defs

!!! Atenção

    Você sempre deve usar os comandos de administração ao invés de editar os arquivos manualmente.

## Gerenciamento de grupos

Arquivos modificados, linhas adicionadas:

* `/etc/grupo`
* `/etc/gshadow`

### Comando `grupoadd`

O comando `groupadd` adiciona um grupo no sistema.
```
groupadd [-f] [-g GID] grupo
```

Exemplo:

```
$ sudo groupadd -g 1012 GrupoB
```

| Opção    | Descrição                                                                                                                           |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `-g GID` | `GID` do grupo a ser criado.                                                                                                        |
| `-f`     | O sistema escolhe um `GID` se o especificado pela opção `-g` já existir.                                                            |
| `-r`     | Cria um grupo de sistema com um `GID` entre `SYS_GID_MIN` e `SYS_GID_MAX`. Essas duas variáveis são definidas em `/etc/login.defs`. |

Regras de nomenclatura do grupo:

* Sem acentos ou caracteres especiais;
* Diferente do nome de um usuário ou arquivo de sistema existentes.

!!! Nota

    No **Debian**, o administrador deve usar, exceto em scripts destinados a serem portáteis para todas as distribuições Linux, os comandos `addgroup` e `delgroup`, como especificado no `man`:

    ```
    $ man addgroup
    DESCRIPTION
    adduser and addgroup add users and groups to the system according to command line options and configuration information
    in /etc/adduser.conf. Eles são atalhos com nomes amigáveis para as ferramentas de baixo nível como os programas useradd, groupadd e usermod,
    por padrão escolhendo valores de política compatível com UID e GID do Debian, criando um diretório raiz com configuração estrutural,
    executando um script personalizado e outros recursos.
    ```

### Comando `groupmod`

O comando `groupmod` permite que você modifique um grupo existente no sistema.

```
groupmod [-g GID] [-n nom] grupo
```

Exemplo:

```
$ sudo groupmod -g 1016 GrupoP
$ sudo groupmod -n GrupoC GrupoB
```

| Opção     | Descrição                             |
| --------- | ------------------------------------- |
| `-g GID`  | Novo `GID` do grupo a ser modificado. |
| `-n nome` | Novo nome.                            |

É possível alterar o nome de um grupo, seu `GID` ou ambos simultaneamente.

Após a modificação, os arquivos pertencentes ao grupo têm um `GID` desconhecido. Eles devem ser reatribuídos ao novo `GID`.

```
$ sudo find / -gid 1002 -exec chgrp 1016 {} \;
```

### Comando `groupdel`

O comando `groupdel` é usado para excluir um grupo existente no sistema.

```
groupdel grupo
```

Exemplo:

```
$ sudo groupdel GrupoC
```

!!! Dica

    Ao excluir um grupo, podem ocorrer duas situações:

    * Se um usuário tem um grupo primário e você digita o comando `groupdel` nesse grupo, você será avisado de que há um usuário específico no grupo e ele não pode ser excluído.
    * Se um usuário pertence a um grupo suplementar (não o grupo primário para o usuário) e esse grupo não é o grupo primário para outro usuário do sistema, então o comando `groupdel` excluirá o grupo sem quaisquer confirmações adicionais.

    Exemplo:

    ```bash
    Shell > useradd testa
    Shell > id testa
    uid=1000(testa) gid=1000(testa) group=1000(testa)
    Shell > groupdel testa
    groupdel: cannot remove the primary group of user 'testa'

    Shell > groupadd -g 1001 testb
    Shell > usermod -G testb root
    Shell > id root
    uid=0(root) gid=0(root) group=0(root),1001(testb)
    Shell > groupdel testb
    ```

!!! Dica

    Quando você excluir um usuário utilizando o comando `userdel -r`, o grupo primário correspondente também será excluído. O nome do grupo primário é geralmente o mesmo do nome de usuário.

!!! Dica

    Cada grupo possui um `GID` único. Um grupo pode ser usado por vários usuários como um grupo complementar. Por convenção, o GID do super administrador é 0. Os GIDS reservados para alguns serviços ou processos são 201~999, que são chamados grupos de sistema ou grupos de pseudo usuários. O GID para usuários geralmente é maior ou igual a 1000. Esses estão relacionadas ao <font color=red>/etc/login.defs</font>, sobre o qual vamos falar mais tarde.

    ```bash
    # Linha de comentário ignorada
    shell > cat  /etc/login.defs
    MAIL_DIR        /var/spool/mail
    UMASK           022
    HOME_MODE       0700
    PASS_MAX_DAYS   99999
    PASS_MIN_DAYS   0
    PASS_MIN_LEN    5
    PASS_WARN_AGE   7
    UID_MIN                  1000
    UID_MAX                 60000
    SYS_UID_MIN               201
    SYS_UID_MAX               999
    GID_MIN                  1000
    GID_MAX                 60000
    SYS_GID_MIN               201
    SYS_GID_MAX               999
    CREATE_HOME     yes
    USERGROUPS_ENAB yes
    ENCRYPT_METHOD SHA512
    ```

!!! Dica

    Como um usuário necessariamente é parte de um grupo, é melhor criar os grupos antes de adicionar os usuários. Portanto, um grupo pode não ter membros.

### Arquivo `/etc/group`

Este arquivo contém as informações do grupo (separadas por `:`).

```
$ sudo tail -1 /etc/group
GrupoP:x:516:patrick
  (1)  (2)(3)   (4)
```

* 1: Nome do grupo.
* A senha do grupo é identificada por `x`. A senha do grupo é armazenada em `/etc/gshadow`.
* 3: GID.
* 4: Usuários complementares do grupo (excluindo o usuário primário).

!!! Nota

   Cada linha no arquivo `/etc/group` corresponde a um grupo. A informação do usuário primário é armazenada em `/etc/passwd`.

### Arquivo `/etc/gshadow`

Este arquivo contém informações de segurança sobre os grupos (separadas por `:`).

```
$ sudo grep GrupoA /etc/gshadow
GrupoA:$6$2,9,v...SBn160:alain:rockstar
   (1)      (2)            (3)      (4)
```

* 1: Nome do grupo.
* 2: Senha criptografada.
* 3: Nome do administrador do grupo.
* 4: Usuários complementares do grupo (excluindo o usuário primário).

!!! Atenção

    O nome do grupo em **/etc/group** e **/etc/gshadow** devem corresponder um por um, ou seja, cada linha no arquivo **/etc/group** deve ter uma linha correspondente no arquivo **/etc/gshadow**.

Um `!` na senha indica que ela está bloqueada. Assim, nenhum usuário pode usar a senha para acessar o grupo (já que os membros do grupo não precisam dela).

## Gerenciamento de usuários

### Definição

Um usuário é definido como a seguir no arquivo `/etc/passwd`:

* 1: Nome de login;
* 2: Identificação da senha, `x` indica que o usuário tem uma senha, a senha criptografada é armazenada no segundo campo de `/etc/shadow`;
* 3: UID;
* 4: GID do grupo primário;
* 5: Comentários;
* 6: Diretório home;
* 7: Shell (`/bin/bash`, `/bin/nologin`, ...).

Existem três tipos de usuários:

* **root(uid=0)**: o administrador do sistema;
* **Usuários do sistema(uid está entre 201~999)**: Usados pelo sistema para gerenciar direitos de acesso de aplicativos;
* **usuário comum(uid>=1000)**: Outra conta para logar no sistema.

Arquivos modificados, linhas adicionadas:

* `/etc/passwd`
* `/etc/shadow`

### Comando `useradd`

O comando `useradd` é usado para adicionar um usuário.

```
useradd [-u UID] [-g GID] [-d diretório] [-s shell] login
```

Exemplo:

```
$ useradd -u 1000 -g 1013 -d /home/GrupoC/carine carine
```

| Opção               | Descrição                                                                                                                                                                              |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-u UID`            | `UID` do usuário a ser criado.                                                                                                                                                         |
| `-g GID`            | `GID` do grupo primário. O `GID` aqui também pode ser um `nome de grupo`.                                                                                                              |
| `-G GID1,[GID2]...` | `GID` dos grupos complementares. O `GID` aqui também pode ser um `nome de grupo`. Vários grupos suplementares podem ser especificados, separados por vírgulas.                         |
| `-d diretório`      | Diretório home.                                                                                                                                                                        |
| `-s shell`          | Shell.                                                                                                                                                                                 |
| `-c COMENTÁRIO`     | Adiciona um comentário.                                                                                                                                                                |
| `-U`                | Adiciona o usuário a um grupo com o mesmo nome criado simultaneamente. Se esta opção não for informada, por padrão, um grupo com o mesmo nome será criado quando o usuário for criado. |
| `-M`                | Não cria o diretório home do usuário.                                                                                                                                                  |
| `-r`                | Cria uma conta de sistema.                                                                                                                                                             |

Ao criar, a conta não tem senha e está bloqueada.

Uma senha deve ser atribuída para desbloquear a conta.

Quando o comando `useradd` não tem nenhuma opção, ele:

* Cria um diretório home com o mesmo nome;
* Cria um grupo primário com o mesmo nome;
* Define o bash como shell padrão;
* O `uid` e o `grupo primário` são registrados automaticamente a partir de 1000, e geralmente o uid e o gid são os mesmos.

```bash
Shell > useradd test1

Shell > tail -n 1 /etc/passwd
test1:x:1000:1000::/home/test1:/bin/bash

Shell > tail -n 1 /etc/shadow
test1:!!:19253:0:99999:7
:::

Shell > tail -n 1 /etc/group ; tail -n 1 /etc/gshadow
test1:x:1000:
test1:!::
```

Regras de nomenclatura da conta:

* Sem acentos, letras maiúsculas ou caracteres especiais;
* Diferente do nome de um grupo ou arquivo de sistema existentes;
* Opcional: defina as opções `-u`, `-g`, `-d` e `-s` na criação.

!!! Atenção

    A árvore do diretório home deve ser criada, exceto para o último diretório.

O último diretório é criado pelo comando `useradd`, que aproveita a oportunidade para copiar os arquivos de `etc/skel` para ele.

**Um usuário pode pertencer a vários grupos além do seu grupo primário.**

Exemplo:

```
$ sudo useradd -u 1000 -g GrupoA -G GrupoP,GrupoC albert
```

!!! Nota

    No **Debian**, você terá que especificar a opção `-m` para forçar a criação do diretório de login ou definir a variável `CREATE_HOME` no arquivo `/etc/login.defs`. Em todos os casos, o administrador deve usar os comandos `adduser` e `deluser`, como especificado no `man`, exceto em scripts destinados a serem portáteis para todas as distribuições Linux:

    ```
    $ man useradd
    DESCRIPTION
        **useradd** é um utilitário de baixo nível para adicionar usuários. No Debian, os administradores geralmente devem usar **adduser(8)**
         em vez disso.
    ```

#### Valor padrão para a criação do usuário.

Modificação do arquivo `/etc/default/useradd`.

```
useradd -D [-b directory] [-g grupo] [-s shell]
```

Exemplo:

```
$ sudo useradd -D -g 1000 -b /home -s /bin/bash
```

| Opção          | Descrição                                                                   |
| -------------- | --------------------------------------------------------------------------- |
| `-D`           | Define os valores padrão para a criação do usuário.                         |
| `-b diretório` | Define o diretório padrão de login.                                         |
| `-g grupo`     | Define o grupo padrão.                                                      |
| `-s shell`     | Define o shell padrão.                                                      |
| `-f`           | O número de dias após a expiração da senha antes da conta ser desabilitada. |
| `-e`           | A data em que a conta será desativada.                                      |

### Comando `usermod`

O comando `usermod` permite modificar um usuário.

```
usermod [-u UID] [-g GID] [-d diretório] [-m] login
```

Exemplo:

```
$ sudo usermod -u 1044 carine
```

Opções idênticas ao comando `useradd`.

| Opção           | Descrição                                                                                                                                                                                                                   |
| --------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-m`            | Associado com a opção `-d` move o conteúdo do diretório de login antigo para o novo. Se o diretório home antigo não existir, um novo diretório home não será criado; Se o diretório home novo não existir, ele será criado. |
| `-l login`      | Novo nome de usuário. Depois de modificar o nome de usuário, você também precisa modificar o nome do diretório home para coincidir com ele.                                                                                 |
| `-e AAAA-MM-DD` | Data de vencimento da conta.                                                                                                                                                                                                |
| `-L`            | Bloqueie a conta permanentemente. Isso é, um `!` é adicionado no início do campo de senha em `/etc/shadow`                                                                                                                  |
| `-U`            | Desbloqueia a conta.                                                                                                                                                                                                        |
| `-a`            | Acrescenta os grupos suplementares do usuário, que devem ser usados juntamente com a opção `-G`.                                                                                                                            |
| `-G`            | Modifique os grupos suplementares do usuário para substituir os grupos suplementares anteriores.                                                                                                                            |

!!! Dica

    Para ser modificado, um usuário deve ser desconectado e não ter processos em execução.

Após alterar o identificador, os arquivos pertencentes ao usuário ficam com um `UID` desconhecido. Deve ser reatribuído a eles o novo `UID`.

Onde `1000` é o antigo `UID` e `1044` é o novo. Os exemplos são os seguintes:

```
$ sudo find / -uid 1000 -exec chown 1044: {} \;
```

Exemplos de bloqueio e desbloqueio da conta de usuário, são os seguintes:

```
Shell > usermod -L test1
Shell > grep test1 /etc/shadow
test1:!$6$n.hxglA.X5r7X0ex$qCXeTx.kQVmqsPLeuvIQnNidnSHvFiD7bQTxU7PLUCmBOcPNd5meqX6AEKSQvCLtbkdNCn.re2ixYxOeGWVFI0:19259:0:99999:7
:::

Shell > usermod -U test1
```

A diferença entre a opção `-aG` e a opção `-G` pode ser explicada pelo seguinte exemplo:

```bash
Shell > useradd test1
Shell > passwd test1
Shell > groupadd grupoA ; groupadd grupoB ; groupadd grupoC ; groupadd grupoD
Shell > id test1
uid=1000(test1) gid=1000(test1) groups=1000(test1)

Shell > gpasswd -a test1 grupoA
Shell > id test1
uid=1000(test1) gid=1000(test1) groups=1000(test1),1002(grupoA)

Shell > usermod -G grupoB,grupoC test1
Shell > id test1 
uid=1000(test1) gid=1000(test1) gorups=1000(test1),1003(grupoB),1004(grupoC)

Shell > usermod -aG grupoD test1
uid=1000(test1) gid=1000(test1) groups=1000(test1),1003(grupoB),1004(grupoC),1005(grupoD)
```

### Comando `userdel`

O comando `userdel` permite excluir a conta de um usuário.

```
$ sudo userdel -r carine
```

| Opção | Descrição                                                                                             |
| ----- | ----------------------------------------------------------------------------------------------------- |
| `-r`  | Deleta o diretório home do usuário e os arquivos de email localizados no diretório `/var/spool/mail/` |

!!! Dica

    Para ser excluído, um usuário deve ser desconectado e não ter processos em execução.

O comando `userdel` remove as linhas correspondentes em `/etc/passwd`, `/ etc/shadow`, `/etc/group`, `/etc/gshadow`. Conforme mencionado acima, `userdel -r` também irá excluir o grupo primário correspondente ao usuário.

### Arquivo `/etc/passwd`

Este arquivo contém informações do usuário (separadas por `:`).

```
$ sudo head -1 /etc/passwd
root:x:0:0:root:/root:/bin/bash
(1)(2)(3)(4)(5)  (6)    (7)
```

* 1: Nome de login;
* 2: Identificação da senha, `x` significa que o usuário tem uma senha, a senha criptografada é armazenada no segundo campo do `/etc/shadow`;
* 3: UID;
* 4: GID do grupo primário;
* 5: Comentários;
* 6: Diretório home;
* 7: Shell (`/bin/bash`, `/bin/nologin`, ...).

### Arquivo `/etc/shadow`

Este arquivo contém as informações de segurança dos usuários (separadas por `:`).
```
$ sudo tail -1 /etc/shadow
root:$6$...:15399:0:99999:7
:::
 (1)    (2)  (3) (4) (5) (6)(7,8,9)
```

* 1: Nome de login.
* 2: Senha criptografada. Usa o algoritmo de criptografia SHA512, definido pelo `ENCRYPT_METHOD` de `/etc/login.defs`.
* 3: O tempo em que a senha foi alterada pela última vez, o formato do timestamp, em dias. O chamado timestamp é baseado em 1 de janeiro de 1970 como a data inicial. A cada dia que passa, o timestamp é +1.
* 4: Tempo de vida mínimo da senha. Ou seja, o intervalo de tempo entre duas alterações de senha (relacionadas com o terceiro campo), em dias.  Definido pelo `PASS_MIN_DAYS` de `/etc/login. efs`, o padrão é 0, ou seja, quando você mudar a senha pela segunda vez, não há restrição. No entanto, se for de 5, significa que não é permitido alterar a senha dentro de 5 dias, e apenas após 5 dias.
* 5: Tempo de vida máximo da senha. Ou seja, o período de validade da senha (relacionado ao terceiro campo). Definido pelo `PASS_MAX_DAYS` de `/etc/login.defs`.
* 6: Número de dias de aviso antes da senha expirar (relacionado ao quinto campo). O padrão é 7 dias, definido pelo `PASS_WARN_AGE` de `/etc/login.defs`.
* 7: Número de dias de tolerância após a expiração da senha (relacionado ao quinto campo).
* 8: Tempo de expiração da conta, o formato timestamp, em dias. **Note que a expiração de uma conta difere de uma expiração de uma senha. Em caso de expiração da conta, o usuário não terá permissão para conectar-se. Em caso de expiração de uma senha, o usuário não tem permissão para fazer login usando sua senha.**
* 9: Reservado para uso futuro.

!!! Perigo

    Para cada linha no arquivo `/etc/passwd` deve haver uma linha correspondente no arquivo `/etc/shadow`.

Para marcação de hora e conversão de data, consulte o seguinte formato de comando:

```bash
# O timestamp é convertido em uma data, "17718" indica o timestamp a ser preenchido.
Shell > date -d "1970-01-01 17718 days" 

# A data é convertida em um timestamp, "2018-07-06" indica a data a ser preenchida.
Shell > echo $(($(date --date="2018-07-06" +%s)/86400+1))
```

## Proprietários de arquivos

!!! Perigo

    Todos os arquivos pertencem necessariamente a um usuário e um grupo.

O grupo primário do usuário que está criando o arquivo é, por padrão, o grupo proprietário do arquivo.

### Comandos de modificação

#### Comando `chown`

O comando `chown` permite que você altere os proprietários de um arquivo.
```
chown [-R] [-v] login[:grupo] arquivo
```

Exemplo:
```
$ sudo chown root meuarquivo
$ sudo chown albert:GrupoA meuarquivo
```

| Opção | Descrição                                                                  |
| ----- | -------------------------------------------------------------------------- |
| `-R`  | Altera recursivamente o dono do diretório e todos os arquivos dentro dele. |
| `-v`  | Exibe as alterações executadas.                                            |

Para alterar apenas o usuário proprietário:

```
$ sudo chown albert arquivo
```

Para modificar somente o grupo proprietário:

```
$ sudo chown :GrupoA arquivo
```

Alterando o usuário e grupo proprietários:

```
$ sudo chown albert:GrupoA arquivo
```

No exemplo a seguir, o grupo atribuído será o grupo primário do usuário especificado.

```
$ sudo chown albert: arquivo
```

Alterar o proprietário e grupo de todos os arquivos em um diretório

```
$ sudo chown -R albert:GrupoA /dir1
```

### Comando `chgrp`

O comando `chgrp` permite que você altere o grupo de proprietários de um arquivo.

```
chgrp [-R] [-v] grupo arquivo
```

Exemplo:
```
$ sudo chgrp grupo1 arquivo
```

| Opção | Descrição                                                                   |
| ----- | --------------------------------------------------------------------------- |
| `-R`  | Altera recursivamente o grupo do diretório e todos os arquivos dentro dele. |
| `-v`  | Exibe as alterações executadas.                                             |

!!! Nota

    É possível aplicar a um arquivo um proprietário e um grupo de proprietários tomando como referência os de outro arquivo:

```
chown [opções] --reference=ARQUIVOREF ARQUIVO
```

Por exemplo:

```
chown --reference=/etc/groups /etc/etc/senha
```

## Gerenciamento de convidados

### Comando `gpasswd`

O comando `gpasswd` permite gerenciar um grupo.

```
gpasswd [opção] grupo
```

Exemplos:

```
$ sudo gpasswd -A alain GrupoA
[alain]$ gpasswd -a patrick GrupoA
```

| Opção            | Descrição                                                                                   |
| ---------------- | ------------------------------------------------------------------------------------------- |
| `-a USUARIO`     | Adiciona o usuário ao grupo. Para o usuário adicionado, esse grupo é um grupo complementar. |
| `-A USUARIO,...` | Define a lista de usuários administradores.                                                 |
| `-d USUARIO`     | Remove o usuário do grupo.                                                                  |
| `-M USUARIO,...` | Define a lista de membros do grupo.                                                         |

O comando `gpasswd -M` atua como uma modificação, não como adição.

```
# gpasswd GrupoA
New Password:
Re-enter new password:
```

!!! nota

    Além de utilizar `gpasswd -a` para adicionar usuários a um grupo, você pode também utilizar os mencionados antes `usermod -G` ou `usermod -AG`.

### Comando `id`

O comando `id` exibe os nomes dos grupos de um usuário.

```
id USUÁRIO
```

Exemplo:

```
$ sudo id alain
uid=1000(alain) gid=1000(GrupoA) grupos=1000(GrupoA),1016(GrupoP)
```

### Comando `newgrp`

O comando `newgrp` pode selecionar um grupo nos grupos suplementares do usuário como o novo grupo primário **temporário** do usuário. O comando `newgrp` toda vez que você mudar o grupo primário de um usuário, haverá um novo **shell filho** (processo filho). Tome cuidado! **shell filho** e **sub shell** são diferentes.

```
newgrp [grupossecundários]
```

Exemplo:

```
Shell > useradd test1
Shell > passwd test1
Shell > groupadd grupoA ; groupadd grupoB 
Shell > usermod -G grupoA,grupoB test1
Shell > id test1
uid=1000(test1) gid=1000(test1) groups=1000(test1),1001(grupoA),1002(grupoB)
Shell > echo $SHLVL ; echo $BASH_SUBSHELL
1
0

Shell > su - test1
Shell > touch a.txt
Shell > ll
-rw-rw-r-- 1 test1 test1 0 10月  7 14:02 a.txt
Shell > echo $SHLVL ; echo $BASH_SUBSHELL
1
0

# Gera um novo shell filho
Shell > newgrp grupoA
Shell > touch b.txt
Shell > ll
-rw-rw-r-- 1 test1 test1  0 10月  7 14:02 a.txt
-rw-r--r-- 1 test1 grupoA 0 10月  7 14:02 b.txt
Shell > echo $SHLVL ; echo $BASH_SUBSHELL
2
0

# Você pode sair do shell filho digitando o comando `exit`
Shell > exit
Shell > logout
Shell > whoami
root
```

## Protegendo

### Comando `passwd`

O comando `passwd` é usado para gerenciar uma senha.

```
passwd [-d] [-l] [-S] [-u] [login]
```

Exemplos:

```
Shell > passwd -l albert
Shell > passwd -n 60 -x 90 -w 80 -i 10 patrick
```

| Opção     | Descrição                                                                                              |
| --------- | ------------------------------------------------------------------------------------------------------ |
| `-d`      | Remove a senha permanentemente. Para uso exclusivo do root (uid=0).                                    |
| `-l`      | Bloqueia permanentemente a conta do usuário. Para uso do root (uid=0) apenas.                          |
| `-S`      | Exibe o status da conta. Para uso do root (uid=0) apenas.                                              |
| `-u`      | Desbloqueia permanentemente a conta de usuário. Para uso do root (uid=0) apenas.                       |
| `-e`      | Expira a senha permanentemente. Para uso do root (uid=0) apenas.                                       |
| `-n DIAS` | Tempo de vida mínimo da senha. Mudança permanente. Para uso do root (uid=0) apenas.                    |
| `-x DIAS` | Tempo de vida máximo da senha. Mudança permanente. Para uso do root (uid=0) apenas.                    |
| `-w DIAS` | Tempo de alerta antes da expiração. Mudança permanente. Para uso do root (uid=0) apenas.               |
| `-i DIAS` | Prazo antes da desativação quando a senha expira. Mudança permanente. Para uso do root (uid=0) apenas. |

Use `password -l`, ou seja, adicione "!!" no início do campo de senha do usuário correspondente em `/etc/shadow`.

Exemplo:

* Alain altera sua senha:

```
[alain]$ passwd
```

* O root altera a senha do Alain

```
$ sudo passwd alain
```

!!! Nota

    O comando `passwd` está disponível para os usuários alterarem sua senha (a senha antiga é solicitada). O administrador pode alterar as senhas de todos os usuários sem restrição.

Eles terão de cumprir com os requisitos de segurança.

Ao gerenciar contas de usuário por script shell, pode ser útil definir uma senha padrão depois de criar o usuário.

Isso pode ser feito passando a senha no comando `passwd`.

Exemplo:

```
$ sudo echo "azerty,1" | passwd --stdin philippe
```

!!! Atenção

    A senha é inserida em texto simples, `passwd` trata de criptografá-la.

### Comando `chage`

O comando `chage` altera as informações de expiração da senha do usuário.

```
chage [-d data] [-E data] [-I dias] [-l] [-m dias] [-M dias] [-W dias] [login]
```

Exemplo:

```
$ sudo chage -m 60 -M 90 -W 80 -I 10 alain
```

| Opção                | Descrição                                                                                                              |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `-I DIAS`            | Prazo antes da desativação, senha expirada. Mudança permanente.                                                        |
| `-l`                 | Exibe os detalhes da política.                                                                                         |
| `-m DIAS`            | Tempo de vida mínimo da senha. Mudança permanente.                                                                     |
| `-M DIAS`            | Tempo de vida máximo da senha. Mudança permanente.                                                                     |
| `-d ULTIMO_DIA`      | Última alteração da senha. Você pode usar o estilo de timestamp dos dias ou o estilo YYYY-MM-DD. Mudança permanente.   |
| `-E DATA_VENCIMENTO` | Data de vencimento da conta. Você pode usar o estilo de timestamp dos dias ou o estilo YYYY-MM-DD. Mudança permanente. |
| `-W DIAS_AVISO`      | Tempo de aviso antes da expiração. Mudança permanente.                                                                 |

Exemplo:

```
# O comando `chage` também oferece um modo interativo.
$ sudo chage philippe

# A opção `-d` força a senha a ser alterada no login.
$ sudo chage -d 0 philippe
```

![Gerenciamento de conta de usuário com chage](images/chage-timeline.png)

## Gerenciamento avançado

Arquivos de configuração:

* `/etc/default/useradd`
* `/etc/login.defs`
* `/etc/skel`

!!! Nota

    A edição do arquivo `/etc/default/useradd` é feita com o comando `useradd`.
    
    Os outros arquivos devem ser modificados com um editor de texto.

### Arquivo `/etc/default/useradd`

Este arquivo contém as configurações de dados padrão.

!!! Dica

    Ao criar um usuário, se as opções não forem especificadas, o sistema usa os valores padrão definidos em `/etc/default/useradd`.

Este arquivo é modificado pelo comando `useradd -D` (`useradd -D` digitado sem qualquer outra opção exibe o conteúdo do arquivo `/etc/default/useradd`).

```
Shell > grep -v ^# /etc/default/useradd 
GROUP=100
HOME=/home
INACTIVE=-1
EXPIRE=
SHELL=/bin/bash
SKEL=/etc/skel
CREATE_MAIL_SPOOL=yes
```

| Parâmetros          | Comentário                                                                                                                                                                              |
| ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `GROUP`             | GID do grupo principal padrão.                                                                                                                                                          |
| `HOME`              | Define o caminho do nível principal do diretório home dos usuários comuns.                                                                                                              |
| `INACTIVE`          | Número de dias de tolerância após a expiração da senha. Corresponde ao 7° campo do arquivo `/etc/shadow`. O valor `-1` significa que a função de período de tolerância está desativada. |
| `EXPIRE`            | Data de vencimento da conta. Corresponde ao 8º campo do arquivo `/etc/shadow`.                                                                                                          |
| `SHELL`             | Interpretador de comando.                                                                                                                                                               |
| `SKEL`              | Diretório de esqueletos do diretório login.                                                                                                                                             |
| `CREATE_MAIL_SPOOL` | Criação de caixa postal em `/var/spool/mail`.                                                                                                                                           |

Se você não precisa de um grupo primário com o mesmo nome ao criar usuários, você pode fazer isto:

```
Shell > useradd -N test2
Shell > id test2
uid=1001(test2) gid=100(users) groups=100(users)
```

### Arquivo `/etc/login.defs`

```bash
# Linha de comentário ignorada
shell > cat  /etc/login.defs
MAIL_DIR        /var/spool/mail
UMASK           022
HOME_MODE       0700
PASS_MAX_DAYS   99999
PASS_MIN_DAYS   0
PASS_MIN_LEN    5
PASS_WARN_AGE   7
UID_MIN                  1000
UID_MAX                 60000
SYS_UID_MIN               201
SYS_UID_MAX               999
GID_MIN                  1000
GID_MAX                 60000
SYS_GID_MIN               201
SYS_GID_MAX               999
CREATE_HOME     yes
USERGROUPS_ENAB yes
ENCRYPT_METHOD SHA512
```

`UMASK 022`: Isso significa que a permissão para criar um arquivo é 755 (rwxr-xr-x). No entanto, por uma questão de segurança, o GNU/Linux não tem permissão de **x** para arquivos recém-criados, esta restrição se aplica a root(uid=0) e usuários comuns(uid>=1000). Por exemplo:

```
Shell > touch a.txt
Shell > ll
-rw-r--r-- 1 root root     0 Oct  8 13:00 a.txt
```

`HOME_MODE 0700`: As permissões do diretório home de um usuário comum. Não funciona para o diretório home do root.

```
Shell > ll -d /root
dr-xr-x---. 10 root root 4096 Oct  8 13:12 /root

Shell > ls -ld /home/test1/
drwx------ 2 test1 test1 4096 Oct  8 13:10 /home/test1/
```

`USERGROUPS_ENAB yes`: "Quando você excluir um usuário usando o comando `userdel -r`, o grupo primário correspondente também será excluído." Por que? Esse é o motivo.

### Diretório `/etc/skel`

Quando um usuário é criado, seu diretório home e arquivos de ambiente são criados. Você pode pensar nos arquivos no diretório `/etc/skel/` como os modelos de arquivo necessários para criar usuários.

Estes arquivos são automaticamente copiados do diretório `/etc/skel`.

* `.bash_logout`
* `.bash_profile`
* `.bashrc`

Todos os arquivos e diretórios colocados neste diretório serão copiados para a árvore do usuário quando eles forem criados.

## Alteração de identidade

### Comando `su`

O comando `su` permite que você altere a identidade do usuário conectado.

```
su [-] [-c comando] [login]
```

Exemplo:

```
$ sudo su - alain
[albert]$ su - root -c "passwd alain"
```

| Opção        | Descrição                                      |
| ------------ | ---------------------------------------------- |
| `-`          | Carrega o ambiente completo do usuário.        |
| Comando `-c` | Executa o comando sob a identidade do usuário. |

Se o login não for especificado, será `root`.

Usuários padrão terão de digitar a senha para a nova identidade.

!!! Dica

    You can use the `exit`/`logout` command to exit users who have been switched. Deve ser observado que após mudar de usuário, não existe um novo `shell filho` ou `sub shell`, por exemplo:

    ```
    Shell > whoami
    root
    Shell > echo $SHLVL ; echo $BASH_SUBSHELL
    1
    0

    Shell > su - test1
    Shell > echo $SHLVL ; echo $BASH_SUBSHELL
    1
    0
    ```

Atenção, por favor! `su` and `su -` são diferentes, como mostrado no seguinte exemplo:

```
Shell > whoami
test1
Shell > su root
Shell > pwd
/home/test1

Shell > env
...
USER=test1
PWD=/home/test1
HOME=/root
MAIL=/var/spool/mail/test1
LOGNAME=test1
...
```

```
Shell > whoami
test1
Shell > su - root
Shell > pwd
/root

Shell > env
...
USER=root
PWD=/root
HOME=/root
MAIL=/var/spool/mail/root
LOGNAME=root
...
```

Então, quando quiser mudar de usuário, lembre-se de não esquecer o `-`. Como os arquivos de variáveis de ambiente necessários não estão carregados, pode haver problemas na execução de alguns programas.
