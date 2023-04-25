---
title: Introdução ao Linux
---

# Introdução ao Sistema Operacional Linux

Nesse capítulo você vai aprender sobre as distribuições GNU/Linux.

****

**Objetivos**: Nesse capítulo você vai aprender como:

:heavy_check_mark: Descrever os recursos e possíveis arquiteturas de um sistema operacional.   
:heavy_check_mark: Recontar a história do UNIX e GNU/Linux.   
:heavy_check_mark: Escolher a distribuição mais apropriada às suas necessidades.   
:heavy_check_mark: Explicar a filosofia do Software de Código-Aberto e Livre.   
:heavy_check_mark: Descobrir a utilidade do shell.

:checkered_flag: **generalidades**, **linux**, **distribuições**

**Conhecimento**: :star:    
**Complexidade**: :star:

**Tempo de leitura**: 10 minutos

****

## O que é um sistema operacional?

Linux, UNIX, BSD, Windows, e MacOS são todos **sistemas operacionais**.

!!! resumo

    Um sistema operacional é um **conjunto de programas que gerencia os recursos disponíveis de um computador**.

Como parte desse gerenciamento de recursos, o sistema operacional tem que:

* Gerenciar a memória **física** ou **virtual**.
    * A **memória física** é o conjunto de barramentos de RAM e memória cache do processador, que são utilizados para a execução dos programas.
    * A **memória virtual** é um local no disco rígido (a partição de **swap**) que permite o descarregamento da memória física e salvamento do estado atual do sistema em caso de um desligamento do computador por queda de energia.
* Impedir **acesso aos periféricos**. Raramente um programa tem permissão para acessar o hardware diretamente (exceto placas de vídeo em casos específicos).
* Fornecer às aplicações um **gerenciamento de tarefas** aequado. O sistema operacional é responsável por ordenar os processos para ocupar o processador.
* **Proteger os arquivos** de acesso não autorizado.
* **Coletar informações** de programas em uso ou em andamento.

![Operação de um sistema operacional](images/operating_system.png)

## Generalidades UNIX - GNU/Linux

### História

#### UNIX

* **1964 — 1968**: O MULTICS (Serviço Computacional e Informação MULTiplexada) é desenvolvido por MIT, Bell Labs (AT&T) e General Electric.

* **1969 — 1971**: Após a saída da Bell (1969) e da General Electric do projeto, dois desenvolvedores, Ken Thompson e Dennis Ritchie (seguidos posteriormente por Brian Kernighan), achando o MULTICS muito complexo, iniciaram o desenvolvimento do UNIX (Serviço Computacional e Informação UNiplexada). Embora tenha sido criado originalmente em Assembly, os criadores do UNIX desenvolveram a linguagem B e depois a linguagem C (1971) e reescreveram completamente o UNIX. Como foi desenvolvido em 1970, a data de referência (época) para o início dos sistemas UNIX/Linux foi definida em 1 de janeiro de 1970.

A linguagem C permanece como uma das mais linguagens de programação populares hoje. Uma linguagem a nível de hardware que permite a adaptação do sistema operacional a qualquer arquitetura de máquina que tenha um compilador C.

O UNIX é um sistema operacional aberto e em evolução que tem desempenhado um papel de destaque na história da computação. Ele forma a base de vários outros sistemas, como Linux, BSD, MacOS, entre outros.

O UNIX ainda tem relevância atualmente (HP-UX, AIX, Solaris, etc.).

#### Projeto GNU

* **1984**: Richard Matthew Stallman lançou o Projeto GNU (GNU Não é Unix), que visava criar um sistema Unix **livre** e **aberto**, onde as ferramentas mais importantes eram: compilador gcc, shell bash, editor Emacs e assim por diante. O GNU é um sistema operacional do tipo Unix. O desenvolvimento do GNU, iniciado em janeiro de 1984, é conhecido como Projeto GNU. Muitos dos programas no GNU foram liberados sob as diretrizes do Projeto GNU; chamamos esses programas de pacotes GNU.

* **1990**: O kernel próprio do GNU, o GNU Hurd, foi iniciado em 1990 (antes do início do Linux).

#### MINIX

* **1987**: Andrew S. Tanenbaum desenvolve o MINIX, um UNIX simplificado, para ensinar sistemas operacionais de uma maneira simples. O Sr. Tanenbaum disponibiliza o código-fonte do seu sistema operacional.

#### Linux

* **1991**: Um estudante finlandês, **Linus Torvalds**, cria um sistema operacional que roda em seu computador pessoal e o chama de Linux. Ele publica sua primeira versão, chamada 0.02, num fórum de discussão da Usenet e outros desenvolvedores ajudam-no a melhorar seu sistema. O termo Linux é um trocadilho entre o primeiro nome do fundador, Linux, e UNIX.

* **1993**: A distribuição Debian é criada. O Debian é uma distribuição não comercial baseada na comunidade. Originalmente criada para uso em servidores, foi adequada para essa função; entretanto é um sistema universal, sendo possível utilizar em um computador pessoal também. O Debian forma a base para várias outras distribuições, como Mint ou Ubuntu.

* **1994**: A distribuição comercial Red Hat é criada pela companhia Red Hat, que é hoje a principal distribuidora do sistema operacional GNU/Linux. A Red Hat apoia a versão da comunidade do Fedora e, até recentemente, a distribuição gratuita CentOS.

* **1997**: O ambiente gráfico KDE é criado. Ele é baseado na biblioteca de componentes Qt e na linguagem de programação C++.

* **1999**: O ambiente gráfico GNOME é criado. Ele é baseado na biblioteca de componentes GTK+.

* **2002**: A distribuição Arch é criada. Seu diferencial é que ela oferece lançamentos constantes (atualização contínua).

* **2004**: O Ubuntu é criado pela companhia Canonical company (Mark Shuttleworth). Ele é baseado em Debian, mas inclui software livre proprietário.

* **2021**: O Rocky Linux é criado, baseado na distribuição Red Hat.

!!! informação

    Disputa sobre o nome: embora as pessoas estejam acostumadas a chamar o Linux de sistema operacional, o Linux é apenas um kernel. Também não podemos esquecer da contribuição e desenvolvimento do projeto GNU para a causa do código aberto! Prefiro chamá-lo sistema operacional GNU/Linux.

### Participação de mercado

<!--
TODO: graphics with market share for servers and pc.
-->

Apesar da sua relevância, o Linux permanece relativamente desconhecido do público em geral. O Linux está escondido em **smartfones**, **televisões**, **modems de internet**, etc. Quase **70% dos sites** do mundo são hospedados em um servidor Linux ou UNIX!

O Linux está instalado em cerca de **3% dos computadores pessoais**, mas em mais de **82% dos smartfones**. O sistema operacional **Android**, por exemplo, utiliza um kernel Linux.

<!-- TODO: review those stats -->

O Linux está instalado em 100% dos 500 principais supercomputadores desde 2018. Um supercomputador é um computador criado para alcançar o maior desempenho possível com as técnicas conhecidas no momento de sua concepção, especialmente no que diz respeito à velocidade computacional.

### Projeto arquitetônico

* O **kernel** é o primeiro componente do software.
    * Ele é o coração do sistema Linux.
    * Ele gerencia os recursos físicos do sistema.
    * Os outros programas devem passar por ele para ter acesso ao hardware.
* O **shell** é um utilitário que interpreta comandos do usuário e garante sua execução.
    * Principais shells: Bourne shell, C shell, Korn shell and Bourne-Again shell (bash).
* **Aplicações** são programas de usuários, incluindo, mas não limitados a:
    * Navegadores de internet
    * Editores de texto
    * Editores de planilhas

#### Multi-tarefa

O Linux pertence à família de sistemas operacionais que compartilham processamento. Ele divide o processamento entre diversos programas, alternando entre um e outro de maneira transparente para o usuário. Isso implica em:

* Execução simultânea de diversos progrmas.
* Distribuição do processamento de CPU pelo controlador.
* Redução dos problemas causados pela falha de uma aplicação.
* Redução de performance no caso de muitos programas em execução.

#### Multi-usuário

O propósito do MULTICS era permitir diversos usuários trabalharem de diversos terminais (teclado e mouse) a partir de um único computador (muito caro na época). O Linux, inspirado por esse sistema operacional, manteve essa habilidade de trabalhar com diversos usuários simultaneamente e independentemente, cada um tendo sua própria conta de usuário com memória e direitos de acesso a arquivos e sistemas.

#### Multi-processador

O Linux consegue trabalhar com computadores de multi-processadores ou processadores multi-núcleos.

#### Multi-plataforma

O Lnux é escrito em uma linguagem de alto nível que pode ser adaptada a diferentes tipos de plataformas durante a compilação. Isso permite que ele seja executado em:

* Computadores domésticos (PC e notebook)
* Servidores (dados e aplicações)
* Dispositivos portáteis (smartfones e tablets)
* Sistemas embarcados (computadores de bordo automotivos)
* Dispositivos de rede (roteadores e switches)
* Aparelhos domésticos (TVs e refrigeradores)

#### Aberto

O Linux é baseado em padrões reconhecidos, como [POSIX](http://en.wikipedia.org/wiki/POSIX), [TCP/IP](https://en.wikipedia.org/wiki/Internet_protocol_suite), [NFS](https://en.wikipedia.org/wiki/Network_File_System), e [Samba](https://en.wikipedia.org/wiki/Samba_(software)), que lhe permite compartilhar dados e serviços com outros sistemas.

### A Filosofia UNIX/Linux

* Tratar tudo como arquivo.
* Valorizar a portabilidade.
* Fazer uma coisa e fazê-la bem feita.
* KISS: Mantnha Isso Simples, Idiota (Keep It Simple, Stupid).
* "O UNIX é basicamente um sistema operacional, mas você precisa ser um gênio para entender a simplicidade." (__Dennis Ritchie__)
* "O Unix é amigável. Ele apenas não é claro a respeito de com quem será amigável." (__Steven King__)

## As distribuições GNU/Linux

Uma distribuição Linux é um **conjunto consistente de software** montado em torno do kernel do Linux, pronto para ser instalado juntamente com os componentes para eu gerenciamento (instalação, remoção, configuração). Existem distribuições **associativas** ou **comunitárias** (Debian, Rocky) e distribuições **comerciais** (Red Hat, Ubuntu).

Cada distribuição oferece um ou mais **ambientes gráficos** e fornece um conjunto de programas pré-instalados e uma biblioteca de programas adicional. As opções de configuração (kernel ou opções de serviços, por exemplo) são específicas para cada distribuição.

Este princípio permite que as distribuições sejam adaptadas para **iniciantes** (Ubuntu, Linux Mint...), ou totalmente personalizáveis para **usuários avançados** (Gentoo, Arch); as distribuições também podem ser mais adequadas para **servidores** (Debian, Red Hat), ou **estações de trabalho** (Fedora).

### Ambientes gráficos

Existem muitos ambientes gráficos, como **GNOME**, **KDE**, **LXDE**, **XFCE**, etc. Existem interfaces para todos, e a sua **ergonomia** não perde em nada para os sistemas Microsoft ou Apple.

Então por que há tão pouco entusiasmo em relação ao Linux, sendo que este sistema é praticamente **livre de vírus**? Pode ser porque muitos editores (Adobe) e fabricantes (Nvidia) não aderem ao jogo do software livre e não fornecem uma versão de seus programas ou __drivers__ para GNU/Linux? Talvez seja medo da mudança, ou a dificuldade de encontrar onde comprar um computador com Linux, ou poucos jogos distribuídos para Linux. Essa última justificativa, pelo menos, não deve durar muito, com o advento do motor de jogo da Steam para Linux.

![Ambiente gráfico GNOME](images/01-presentation-gnome.png)

O ambiente **GNOME 3** não usa mais o conceito de área de trabalho, mas sim o de GNOME Shell (não deve ser confundido com a linha de comando shell). Ele serve como área de trabalho, painel de controle, área de notificações e um seletor de janela. O ambiente de trabalho GNOME é baseado na biblioteca de componentes **GTK+**.

![Ambiente gráfico KDE](images/01-presentation-kde.png)

O ambiente gráfico **KDE** é baseado na biblioteca de componentes **Qt**. Ele é normalmente recomendado para usuários familiarizados com ambiente Windows.

![Tux - O mascote Linux](images/tux.png)

### Livre / Código Aberto

Um usuário de um sistema operacional Windows ou Mac deve comprar uma licença para a utilização do sistema. Essa licença tem um custo, embora geralmente não apareça (o preço da licença está incluído no preço do computador).

No universo **GNU/Linux**, o movimento Software Livre fornece principalmente distribuições livres.

**Livre** não significa grátis!

**Código Aberto**: o código-fonte é disponibilizado, por isso é possível consultá-lo e modificá-lo sob certas condições.

Um software livre é necessariamente de código aberto, mas o oposto não é verdade, já que o software de código aberto é diferente da liberdade oferecida pela licença GPL.

#### GNU GPL (Licença Pública Geral GNU)

A **GPL** garante ao autor de um software a sua propriedade intelectual, mas permite modificação, redistribuição ou revenda do programa por terceiros, desde que o código-fonte esteja incluído no software. A GPL é a licença que veio do projeto **GNU** (GNU Não é UNIX), que foi fundamental na criação do Linux.

Isso implica:

* A liberdade de executar o programa, para qualquer finalidade.
* A liberdade para estudar como o programa funciona e adaptá-lo às suas necessidades.
* A liberdade para redistribuir cópias.
* A liberdade para melhorar o programa e publicar essas melhorias para o benefício de toda a comunidade.

Por outro lado, até mesmo os produtos licenciados sob a GPL podem ter um custo. Isto não é para o produto em si, mas a **garantia que uma equipe de programadores continuará trabalhando nele para fazer com que evolua e resolver problemas, ou até mesmo fornecer suporte a usuários**.

## Áreas de uso

Uma distribuição Linux é ideal para:

* **Servidores**: HTTP, email, programas colaborativos, compartilhamento de arquivos, etc.
* **Segurança**: Gateway, firewall, roteador, proxy, etc.
* **Computadores centrais**: Bancos, seguradoras, indústria, etc.
* **Sistemas embarcados**: Roteadores, Modems de Internet, SmartTVs, etc.

O Linux é uma escolha adequada para hospedar bancos de dados ou sites web, ou como um servidor de correio eletrônico, DNS ou firewall. Resumindo, o Linux pode fazer praticamente qualquer coisa, o que explica a quantidade de distribuições específicas.

## Shell

### Geral

O **shell**, conhecido como _linha de comando_, permite que os usuários enviem comandos para o sistema operacional. É menos visível hoje, desde a implementação dos ambientes gráficos, mas continua a ser um meio privilegiado em sistemas Linux, onde nem todos possuem interfaces gráficas e cujos serviços nem sempre têm uma interface de configuração.

Oferece uma verdadeira linguagem de programação, incluindo as estruturas clássicas (loops de repetição, estruturas condicionais) e os constituintes comuns (variáveis, passagem de parâmetros e subprogramas). Permite a criação de scripts para automatizar determinadas ações (backups, criação de usuários, monitoramento de sistemas, etc.).

Existem vários tipos de shells disponíveis e configuráveis em uma plataforma ou conforme a preferência do usuário. Alguns exemplos incluem:

* sh, o shell padrão do POSIX
* csh, shell orientado a comando em C
* bash, Bourne-Again Shell, shell Linux

### Funcionalidades

* Execução de comando (verifica o comando informado e o executa).
* Redirecionamento de Entrada/Saída (salva os dados em um arquivo, ao invés de exibi-los na tela).
* Processo de conexão (gerencia a conexão do usuário).
* Interpretação de linguagem de programação (permitindo a criação de scripts).
* Variáveis de ambiente (acesso a informações específicas do sistema durante a operação).

### Base

![Princípio de operação do SHELL](images/shell-principle.png)

## Teste os seus conhecimentos

:heavy_check_mark: Um sistema operacional é um conjunto de programas para gerenciar os recursos disponíveis de um computador:

- [ ] Verdadeiro
- [ ] Falso

:heavy_check_mark: O sistema operacional é necessário para:

- [ ] Gerenciar a memória física e virtual
- [ ] Permitir acesso direto aos periféricos
- [ ] Terceirizar o gerenciamento de tarefas para o processador
- [ ] Coletar informações sobre os programas utilizados ou em uso

:heavy_check_mark: Dentre essas personalidades, quais participaram do desenvolvimento do UNIX:

- [ ] Linus Torvalds
- [ ] Ken Thompson
- [ ] Lionel Richie
- [ ] Brian Kernighan
- [ ] Andrew Stuart Tanenbaum

:heavy_check_mark: A nacionalidade original de Linus Torvalds, criador do kernel Linux, é:

- [ ] Sueca
- [ ] Finlandesa
- [ ] Norueguesa
- [ ] Flamenga
- [ ] Francesa

:heavy_check_mark: Qual das seguintes distribuições é a mais antiga:

- [ ] Debian
- [ ] Slackware
- [ ] Red Hat
- [ ] Arch

:heavy_check_mark: O kernel Linux é:

- [ ] Multi-tarefa
- [ ] Multi-usuário
- [ ] Multiprocessador
- [ ] Multi-core
- [ ] Multiplataforma
- [ ] Aberto

:heavy_check_mark: O software livre é necessariamente de código aberto?

- [ ] Verdadeiro
- [ ] Falso

:heavy_check_mark: O software de código aberto é necessariamente livre?

- [ ] Verdadeiro
- [ ] Falso

:heavy_check_mark: Qual dos seguintes não é um shell:

- [ ] Jason
- [ ] Jason-Bourne shell (jbsh)
- [ ] Bourne-Again shell (bash)
- [ ] C shell (csh)
- [ ] Korn shell (ksh)   
