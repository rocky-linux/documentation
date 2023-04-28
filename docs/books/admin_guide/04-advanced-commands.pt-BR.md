---
title: Comandos Avançados Linux
---

# Comandos Avançados para Usuários Linux

Comandos avançados permitem grande customização e controle em situações específicas uma vez que você já esteja familiarizado com os comandos básicos.

****

**Objetivos**: Neste capítulo, os futuros administradores do Linux vão aprender:

:heavy_check_mark: alguns comandos úteis não cobertos no capítulo anterior.   
:heavy_check_mark: alguns comandos avançados.

:checkered_flag: **comando de usuário**, **Linux**

**Conhecimento**: :star:   
**Complexidade**: :star: :star: :star:

**Tempo de leitura**: 20 minutos

****

## Comando `uniq`

O comando `uniq` é um comando muito poderoso, usado com o comando `sort`, especialmente para análise de arquivo de log. Ele permite classificar e exibir as entradas removendo duplicidades.

Para ilustrar como o comando `uniq` funciona, vamos usar um arquivo `firstnames.txt` contendo uma lista dos primeiros nomes:

```
antoine
xavier
steven
patrick
xavier
antoine
antoine
steven
```

!!! Nota

    `uniq` requer que o arquivo de entrada seja ordenado antes da execução, porque compara apenas linhas consecutivas.

Se nenhum argumento for passado, o comando `uniq` não irá exibir linhas idênticas consecutivas no arquivo `firstnames.txt`:

```
$ sort firstnames.txt | uniq
antoine
patrick
steven
xavier
```

Para exibir somente as linhas que aparecem apenas uma vez, use a opção `-u`:

```
$ sort firstnames.txt | uniq -u
patrick
```

Por outro lado, para exibir apenas as linhas que aparecem pelo menos duas vezes no arquivo, você deve usar a opção `-d`:

```
$ sort firstnames.txt | uniq -d
antoine
steven
xavier
```

Para simplesmente excluir linhas que aparecem apenas uma vez, use a opção `-D`:

```
$ sort firstnames.txt | uniq -D
antoine
antoine
antoine
steven
steven
xavier
```

Por fim, para contar o número de ocorrências de cada linha, use a opção `-c`:

```
$ sort firstnames.txt | uniq -c
      3 antoine
      1 patrick
      2 steven
      2 xavier
```

```
$ sort firstnames.txt | uniq -cd
      3 antoine
      2 steven
      2 xavier
```

## Comandos do `xargs`

O comando `xargs` permite a construção e execução de linhas de comando da entrada padrão.

O comando `xargs` lê espaços em branco ou argumentos diretos delimitados da entrada padrão e executa o comando (`/bin/echo` por padrão) uma ou mais vezes usando os argumentos iniciais seguidos pelos argumentos lidos da entrada padrão.

Um primeiro e simples exemplo seria o seguinte:

```
$ xargs
uso
do
xargs
<CTRL+D>
uso do xargs
```

O comando `xargs` espera pelo dado da entrada padrão **stdin**. Três linhas são inseridas. O fim da entrada do usuário é especificado para o `xargs` pela sequência de teclas <kbd>CTRL</kbd>+<kbd>D</kbd>. O `xargs` então executa o comando padrão `echo` seguido pelos três argumentos correspondentes à entrada do usuário, ou seja:

```
$ echo "uso" "do" "xargs"
uso do xargs
```

É possível especificar o comando a ser executado pelo `xargs`.

No exemplo a seguir, o `xargs` executará o comando `ls -ld` no conjunto de pastas especificadas na entrada padrão:

```
$ xargs ls -ld
/home
/tmp
/root
<CTRL+D>
drwxr-xr-x. 9 root root 4096  5 avril 11:10 /home
dr-xr-x---. 2 root root 4096  5 avril 15:52 /root
drwxrwxrwt. 3 root root 4096  6 avril 10:25 /tmp
```

Na prática, o comando `xargs` executou o comando `ls -ld /home /tmp /root`.

O que acontece se o comando a ser executado não aceitar vários argumentos, como é o caso com o comando `find`?

```
$ xargs find /var/log -name
*.old
*.log
find: paths must precede expression: *.log
```

O comando `xargs` tentou executar o comando `find` com vários argumentos depois da opção `-name`, o que fez com que `find` gerasse um erro:

```
$ find /var/log -name "*.old" "*.log"
find: paths must precede expression: *.log
```

Neste caso, o comando `xargs` deve ser forçado a executar o comando `find` várias vezes (uma vez por linha digitada como entrada padrão). A opção `-L` seguida de um valor **inteiro** permite que você especifique o número máximo de entradas a serem processadas com o comando de uma só vez:

```
$ xargs -L 1 find /var/log -name
*.old
/var/log/dmesg.old
*.log
/var/log/boot.log
/var/log/anaconda.yum.log
/var/log/anaconda.storage.log
/var/log/anaconda.log
/var/log/yum.log
/var/log/audit/audit.log
/var/log/anaconda.ifcfg.log
/var/log/dracut.log
/var/log/anaconda.program.log
<CTRL+D>
```

Para especificar ambos os argumentos na mesma linha, use a opção `-n 1`:

```
$ xargs -n 1 find /var/log -name
*.old *.log
/var/log/dmesg.old
/var/log/boot.log
/var/log/anaconda.yum.log
/var/log/anaconda.storage.log
/var/log/anaconda.log
/var/log/yum.log
/var/log/audit/audit.log
/var/log/anaconda.ifcfg.log
/var/log/dracut.log
/var/log/anaconda.program.log
<CTRL+D>
```

Estudo de caso de um backup com `tar` baseado em uma pesquisa:

```
$ find /var/log/ -name "*.log" -mtime -1 | xargs tar cvfP /root/log.tar
$ tar tvfP /root/log.tar
-rw-r--r-- root/root      1720 2017-04-05 15:43 /var/log/boot.log
-rw-r--r-- root/root    499270 2017-04-06 11:01 /var/log/audit/audit.log
```

O recurso especial do comando `xargs` é que ele coloca o argumento de entrada no final do comando chamado. Isso funciona muito bem com o exemplo acima, uma vez que os arquivos passados formarão a lista de arquivos a serem adicionados ao arquivo.

Usando o comando `cp` como exemplo, para copiar uma lista de arquivos em um diretório, esta lista de arquivos será adicionada no final do comando... mas o que o comando `cp` espera no final do comando é o destino. Para fazer isso, utilize a opção `-I` para colocar os argumentos de entrada em outro lugar que não no final da linha.

```
$ find /var/log -type f -name "*.log" | xargs -I % cp % /root/backup
```

A opção `-I` permite que você especifique um caractere (no nosso exemplo o caractere `%` ) onde os arquivos de entrada para `xargs` serão colocados.

## Pacote `yum-utils`

O pacote `yum-utils` é uma coleção de utilitários feitos para `yum` por vários autores, que o tornam mais poderoso e mais fácil de usar.

!!! Nota

    Apesar de o `yum` ter sido substituído por `dnf` no Rocky Linux 8, o nome do pacote permaneceu `yum-utils`, embora ele também possa ser instalado como `dnf-utils`. Tratam-se de utilitários clássicos do YUM implementados como apoio em CLI sobre o DNF para mater a compatibilidade com `yum-3`.

Aqui estão alguns exemplos de uso desses utilitários:

* comando `repoquery`

O comando `repoquery` é usado para consultar os pacotes no repositório.

Exemplos de uso:

  * Exibe as dependências de um pacote (pode ser um pacote de software instalado ou não instalado), equivalente a `dnf deplist <package-name>`
    ```
    repoquery --requires <nome-do-pacote>
    ```

  * Exibe os arquivos fornecidos por um pacote instalado (não funciona para pacotes não instalados), equivalente a `rpm -ql <package-name>`

    ```
    $ repoquery -l yum-utils
    /etc/bash_completion.d
    /etc/bash_completion.d/yum-utils.bash
    /usr/bin/debuginfo-install
    /usr/bin/find-repos-of-install
    /usr/bin/needs-restarting
    /usr/bin/package-cleanup
    /usr/bin/repo-graph
    /usr/bin/repo-rss
    /usr/bin/repoclosure
    /usr/bin/repodiff
    /usr/bin/repomanage
    /usr/bin/repoquery
    /usr/bin/reposync
    /usr/bin/repotrack
    /usr/bin/show-changed-rco
    /usr/bin/show-installed
    /usr/bin/verifytree
    /usr/bin/yum-builddep
    /usr/bin/yum-config-manager
    /usr/bin/yum-debug-dump
    /usr/bin/yum-debug-restore
    /usr/bin/yum-groups-manager
    /usr/bin/yumdownloader
    …
    ```

* comando `yumdownloader`:

O comando `yumdownloader` baixa os pacotes RPM dos repositórios.  Equivalente ao `dnf download --downloaddir ./ nome-do-pacote`

!!! Nota

    Este comando é muito útil para criar rapidamente um repositório local de alguns rpms!

Exemplo: `yumdownloader` irá baixar o pacote rpm _samba_ e todas suas dependências:

```
$ yumdownloader --destdir /var/tmp --resolve samba
ou
$ dnf download --downloadonly --downloaddir /var/tmp  --resolve  samba
```

| Opções      | Comentários                                                  |
| ----------- | ------------------------------------------------------------ |
| `--destdir` | Os pacotes baixados serão armazenados na pasta especificada. |
| `--resolve` | Também baixa as dependências do pacote.                      |

## Pacotes `psmisc`

O pacote `psmisc` contém utilitários para gerenciar os processos do sistema:

* `pstree`: o comando `pstree` exibe os processos atuais no sistema em uma estrutura estilo árvore.
* `killall`: o comando `killall` envia um sinal de kill para todos os processos identificados pelo nome.
* `fuser`: o comando `fuser` identifica o `PID` dos processos que usam os arquivos ou sistemas de arquivos especificados.

Exemplos:

```
$ pstree
systemd─┬─NetworkManager───2*[{NetworkManager}]
        ├─agetty
        ├─auditd───{auditd}
        ├─crond
        ├─dbus-daemon───{dbus-daemon}
        ├─firewalld───{firewalld}
        ├─lvmetad
        ├─master─┬─pickup
        │        └─qmgr
        ├─polkitd───5*[{polkitd}]
        ├─rsyslogd───2*[{rsyslogd}]
        ├─sshd───sshd───bash───pstree
        ├─systemd-journal
        ├─systemd-logind
        ├─systemd-udevd
        └─tuned───4*[{tuned}]
```

```
# killall httpd
```

Mata os processos (opção `-k`) que acessam o arquivo `/etc/httpd/conf/httpd.conf`:

```
# fuser -k /etc/httpd/conf/httpd.conf
```

## Comando `watch`

O comando `watch` executa um comando regularmente e exibe o resultado no terminal em tela cheia.

A opção `-n` permite especificar o número de segundos entre cada execução do comando.

!!! Nota

    Para sair do comando `watch`, você deve digitar as teclas: <kbd>CTRL</kbd>+<kbd>C</kbd> para matar o processo.

Exemplos:

* Exibir o final do arquivo `/etc/passwd` a cada 5 segundos:

```
$ watch -n 5 tail -n 3 /etc/passwd
```

Resultado:

```
A cada 5.0s: tail -n 3 /etc/passwd                                                                                                                                rockstar.rockylinux.lan: Thu Jul  1 15:43:59 2021

sssd:x:996:993:User for sssd:/:/sbin/nologin
chrony:x:995:992::/var/lib/chrony:/sbin/nologin
sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
```

* Monitorando o número de arquivos em uma pasta:

```
$ watch -n 1 'ls -l ł wc -l'
```

* Mostrar um relógio:

```
$ watch -t -n 1 date
```
