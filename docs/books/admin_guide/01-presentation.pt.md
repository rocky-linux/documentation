---
title: Introdução ao Linux
---

# Introdução ao Sistema Operacional Linux

Neste capítulo você aprenderá sobre as distribuições GNU/Linux.

****

**Objetivos** : Neste capítulo você vai aprender como:

:heavy_check_mark: Descrever os recursos e possíveis arquiteturas de um sistema operacional   
:heavy_check_mark: Recordar a História do UNIX e GNU/Linux   
:heavy_check_mark: Escolher a distribuição Linux mais adequada para suas necessidades   
:heavy_check_mark: Explicar a filosofia do software livre   
:heavy_check_mark: Compreender a utilidade do SHELL.

:checkered_flag: **generalidades** **, ** linux**, **distribuições**</p>

**Conhecimento**: :star:    
    
**Complexidade**: :star:

**Tempo de leitura**: 10 minutos

****

## O que é um sistema operacional?

Linux, UNIX, BSD, Windows e MacOS são todos **sistemas operacionais**.

!!! Um sistema operacional é um **conjunto de programas que gerencia os recursos disponíveis em um computador**.

Entre esta gestão de recursos, o sistema operacional tem de:

* Gerenciar a memória física ou virtual.
  * A **memória física** é composta pelas barras de memória RAM e pela memória cache do processador, que é usada para a execução de programas.
  * A **memória virtual** é um local no disco rígido (a **partição swap**) que permite descarregar o conteúdo da memória física e salvar do estado atual do sistema durante o desligamento elétrico do computador.
* Gerenciar o acesso aos** periféricos de entrada e saída**. O software raramente tem permissão para acessar hardware diretamente (exceto para placas gráficas em necessidades muito específicas).
* Fornecer aplicativos com **gerenciamento de tarefas** adequado. O sistema operacional é responsável por agendar processos para ocupar o uso do processador.
* **Proteger arquivos** contra acesso não autorizado.
* **Coletar informações** sobre programas em uso ou em andamento.

![Operation of an operating system](images/operating_system.png)

## Generalidades UNIX - GNU/Linux

### História

#### UNIX

* De **1964 a 1968**: MULTICS (Serviço de Informação e Computação MULTiplexado) é desenvolvido para MIT, Bell Labs (AT&T) e General Electric.

* **1969**: Depois que Bell Labs (1969) e da General Electric saíram do projeto, dois desenvolvedores (Ken Thompson e Dennis Ritchie), posteriormente reunido por Brian Kernighan, que considera os MULTICS muito complexos, lançou o desenvolvimento do UNIX (Serviço de Informação e Computação UNIplexado). Originalmente foi desenvolvido em *assembler*, entretanto os desenvolvedores da UNIX desenvolveram a linguagem de programação B e, depois, a linguagem C (1971) e reescreveram completamente o UNIX. Tendo sido desenvolvida em 1970, a data de referência dos sistemas UNIX/Linux ficou estabelecida em Janeiro de 1970.

A linguagem C ainda é uma das linguagens de programação mais populares do mundo! Uma linguagem de baixo nível, perto do *hardware*, permite a adaptação do sistema operacional a qualquer arquitetura de máquinas que tenha um compilador de C.

O UNIX é um sistema operacional aberto e em evolução que desempenhou um papel importante na história da computação. Tem sido a base para muitos outros sistemas operacionais como Linux, BSD, MacOS, etc.

O UNIX ainda é relevante nos dias de hoje (HP-UX, AIX, Solaris, etc.)

#### Minix

* **Complexidade**: :star: **1987**: A.S. Tanenbaum desenvolve MINIX, um UNIX simplificado, com o intuito de ensinar os sistemas operacionais de uma forma simples. O Sr. Tanenbaum disponibiliza o código fonte do seu sistema operacional.

#### Linux

* **1991**: Um estudante finlandês, **Linus Torvalds**, cria um sistema operacional dedicado ao seu computador pessoal e o nomeia como Linux. Ele publica a sua primeira versão 0.02, no fórum de discussão Usenet e outros desenvolvedores vêm para ajudá-lo a melhorar o seu sistema. O termo Linux é uma combinação de palavras entre o primeiro nome do fundador, Linus, e UNIX.

* **1993**: a distribuição do Debian é criada. Debian é uma distribuição não comercial mantida pela comunidade. Originalmente desenvolvido para uso em servidores, é particularmente adequado para esse papel. Mas destina-se a ser um sistema universal, e portanto utilizável também num computador pessoal. O Debian é usado como base para muitas outras distribuições, como Linux Mint e Ubuntu.

* **1994**: a distribuição comercial do RedHat é criada pela empresa RedHat, que é hoje o principal distribuidor do sistema operacional GNU/Linux. RedHat suporta a versão comunitária Fedora e, recentemente, a distribuição livre CentOS.

* **1997**: O ambiente gráfico KDE foi criado. Ele é baseado na biblioteca de componentes Qt e na linguagem de programação C++.

* **1999**: O ambiente gráfico Gnome foi criado. Ele é baseado na biblioteca de componentes GTK+.

* **2002**: a distribuição Arch foi criada. Sua particularidade é ser uma distribuição Rolling Release(com atualizações contínuas).

* **2004**: Ubuntu é criado pela empresa Canonical (Mark Shuttleworth). Baseia-se em Debian, entretanto inclui tanto software livre quanto proprietário.

* **2021**: Nascimento do Rocky Linux, baseado na distribuição RedHat.

### Participação no mercado

<!--
TODO: graphics with market share for servers and pc.
-->

O Linux ainda não é bem conhecido pelo público em geral, embora o mesmo o utilize regularmente. Na verdade, o Linux está escondido em **smartphones**, **televisões**, **modens de internet**, etc. Quase **70% das páginas da web** no mundo estão hospedadas em um servidor Linux ou UNIX! Quase **70% das páginas da web** no mundo estão hospedadas em um servidor Linux ou UNIX!

O Linux está presente em pouco mais de **3% dos computadores pessoais**, mas em mais de **82% dos smartphones**. O **Android** é um sistema operacional cujo kernel é Linux.

<!-- TODO: review those stats -->

Linux está presente em 100% dos supercomputadores desde 2018. Um supercomputador é um computador projetado para alcançar o maior desempenho possível com as técnicas conhecidas no momento de seu design, especialmente no que diz respeito à velocidade da computação.

### Arquitetura do Linux

* O **kernel** é o primeiro componente de software.
  * É o núcleo do sistema Linux.
  * Ele gerencia os recursos de hardware do sistema.
  * Os outros componentes do software devem passar por ele para acessar o hardware.
* O shell **** é um utilitário que interpreta comandos do usuário e garante sua execução.
  * Principais Shells: Bourne shell, C shell, Korn shell e Bourne-Again shell (bash).
* Aplicativos são programas do usuário como:
  * Navegador de Internet;
  * Processadores de Texto;
  * ...

#### Multitarefa

O Linux pertence à família de sistemas operacionais de compartilhamento de tempo. Ele compartilha o tempo de processo entre vários programas, mudando de um para outro de forma transparente para o usuário. Isso implica:

* execução simultânea de vários programas;
* distribuição do tempo de uso da CPU pelo gerenciador de tarefas;
* redução de problemas devido a uma aplicação com falhas;
* redução de desempenho quando muitos programas são executados.

#### Múltiplos usuários

O propósito das Multices era permitir que vários usuários trabalhassem de vários terminais (tela e teclado) em um único computador (muito caro na época). Linux, que é inspirado neste sistema operacional, manteve esta habilidade de trabalhar com vários usuários simultaneamente e independentemente, cada um tem sua própria conta de usuário, espaço de memória e acesso a arquivos e software.

#### Multiprocessadores

O Linux é capaz de trabalhar com computadores multi-processadores ou processadores multi-núcleos(com mais de um núcleo).

#### Multiplataforma

O Linux é escrito em uma linguagem de alto nível que pode ser adaptada a diferentes tipos de plataformas durante sua compilação. Portanto, ele funciona em:

* computadores domésticos (PC ou laptop);
* servidores (dados, aplicações,...);
* computadores portáteis (smartphones ou tablets)
* sistemas embarcados (computador de carro e máquinas)
* elementos de rede ativos (roteadores, interruptores)
* electrodomésticos (TVs, refrigeradores,...).

#### Aberto

O Linux é baseado em padrões reconhecidos [posix](http://fr.wikipedia.org/wiki/POSIX), TCP/IP, NFS, Samba ... permitindo compartilhar dados e serviços com outros sistemas de aplicativo.

### A filosofia UNIX/Linux

* Tudo é um arquivo.
* Portabilidade.
* Faça apenas uma coisa e faça isso bem.
* KISS: Mantenha Isso Simples Estupido(Keep It Simple Stupid).
* "A UNIX é basicamente um sistema operacional simples, mas é preciso ser um gênio para entender a simplicidade." (__Dennis Ritchie__)
* "Unix é amigável ao usuário. No entanto, não específica quais usuários serão amigáveis com o sistema." (__Steven King__)

## As distribuições GNU/LINUX

Uma distribuição Linux é um **conjunto consistente de software** montado em torno kernel do Linux e pronto para ser instalado juntamente com os componentes necessários para gerenciar este software (instalação, remoção, configuração). Existem **distribuições associativas ou comunitárias** (Debian, Rocky) ou **comerciais** (RedHat, Ubuntu).

Cada distribuição oferece um ou mais **ambientes de trabalho**(ambiente gráfico), fornece um conjunto de softwares pré-instalados e uma biblioteca de software adicional. Opções de configuração (configurações do kernel ou opções de serviços, por exemplo) são específicas para cada distribuição.

Este princípio permite que você tenha distribuições orientadas para **iniciantes** (Ubuntu, Linux Mint...), outras com uma abordagem mais complexa (Gentoo, Arch), algumas com foco em **servidores** (Debian, Redhat) e até mesmo distribuições dedicadas a **estações de trabalho**.

### Ambientes de Trabalho(Ambiente Gráfico)

Existem diversos ambientes gráficos: **Gnome**, **KDE**, **LXDE**, **XFCE**, etc. Há interfaces para todos tipos de pessoas, e sua **ergonomia** não perde em nada para os sistemas Microsoft ou Apple!

Então, por que há tão pouco entusiasmo para o Linux sendo que **não há(ou é pouco presente) vírus para esse sistema**? Talvez porque todos os editores(Adobe) ou fabricantes(Nvidia) não jogam o jogo gratuito e dessa forma não fornecem uma versão do seu software compatível com GNU/Linux? Medo da mudança? A dificuldade de onde encontrar e comprar um computador com Linux? Poucos jogos(Mas não por muito tempo) distribuídos no Linux? Essa situação vai mudar com a chegada do console de jogos steam-box que roda com Linux?

![Gnome Desktop](images/01-presentation-gnome.png)

O ambiente gráfico **Gnome 3** não usa mais o conceito de Área de Trabalho(Desktop), mas sim o Gnome Shell(não confundir com o shell da linha de comando). Ele serve como área de trabalho, painel de controle, área de notificações e um seletor de janela. O ambiente gráfico Gnome é baseado na biblioteca de componentes GTK+.

![KDE Desktop](images/01-presentation-kde.png)

O ambiente gráfico **KDE** é baseado na biblioteca de componentes **Qt**.

Ele é mais recomendado para usuários que estão migrando do mundo Windows para o Linux.

![Tux - The Linux mascot](images/tux.png)

### Livre / Código Aberto

Um usuário de um sistema operacional Windows ou Mac deve comprar uma licença para o uso legal do sistema operacional. Essa licença tem um custo, embora geralmente seja oculto ao comprador(o preço da licença está incluído no preço do computador).

No universo **GNU/Linux**, o movimento Software Livre fornece principalmente distribuições livres.

**Grátis** não significa livre!

**Código Aberto**: os códigos-fonte estão disponíveis, por isso é possível consultá-los e modificá-los sob certas condições.

Um software livre é necessariamente Código Aberto, mas o oposto não é verdade, uma vez que um software código aberto é separado da liberdade proposta pela licença GPL.

#### Licença GPL (General Public License)

A **Licença GPL** garante ao autor de um software sua propriedade intelectual, mas permite modificação, redistribuição ou revenda do software por terceiros, desde que os códigos-fonte sejam fornecidos com o software. O GPL é a licença que saiu do projeto **GNU** (GNU não é UNIX), que foi fundamental na criação do Linux.

Isso implica:

* a liberdade de executar o programa, para qualquer finalidade;
* a liberdade de estudar como o programa funciona e adaptá-lo às suas necessidades;
* a liberdade de redistribuir cópias;
* a liberdade de melhorar o programa e publicar suas melhorias em benefício de toda a comunidade.

Por outro lado, até mesmo produtos licenciados sob o GPL podem ser pagos. Este não é o produto em si, mas a garantia de que uma equipe de desenvolvedores continuará trabalhando nele para fazê-lo evoluir e solucionar problemas, ou mesmo fornecer suporte aos usuários.

## Áreas de uso

Uma distribuição Linux se destaca em :

* **Servidores**: HTTP, email, groupware, compartilhamento de arquivo, etc.
* **Segurança**: Gateway, firewall, roteador, proxy, etc.
* **Computador central**: Bancos, seguros, indústria, etc.
* **Sistema embarcado**: roteadores, Internet boxes, SmartTV, etc.

O Linux é uma escolha adequada para hospedar bancos de dados ou sites, ou como um servidor de e-mail, DNS ou firewall. Em suma, o Linux pode fazer qualquer coisa, o que explica a quantidade de distribuições específicas.

## Shell

### Generalidades

O **shell**, conhecido como _linha de comando_, permite que os usuários enviem comandos para o sistema operacional. É menos visível hoje, desde a implementação de ambientes gráficos, mas continua sendo um meio privilegiado em sistemas Linux, onde nem todos possuem interfaces gráficas e cujos serviços nem sempre têm uma interface de configuração.

Oferece uma linguagem de programação real, incluindo as estruturas clássicas: laços de repetição, estruturas condicionais e os constituintes comuns: variáveis, passagem de parâmetros e subprogramas. Permite a criação de scripts para automatizar determinadas ações (backups, criação de usuários, monitoramento de sistemas, etc.).

Existem vários tipos de shells disponíveis e configuráveis em uma plataforma ou de acordo com a preferência do usuário:

* sh, the POSIX standard shell ;
* csh, command-oriented shell in C ;
* bash, Bourne-Again Shell, Linux shell.
* etc, ...

## Funcionalidades

* Execução de comando (verifica o comando dado e o executa);
* Redirecionamento de entrada/saída (retorna dados a um arquivo em vez de escrevê-lo na tela);
* Processo de conexão (gerencia a conexão do usuário);
* Linguagem de programação interpretada (permitindo a criação de scripts);
* Variáveis de ambiente (acesso a informações específicas do sistema durante a operação).

### Princípio

![Operating principle of the SHELL](images/shell-principle.png)

## Verifique seu conhecimento

:heavy_check_mark: Um sistema operacional é um conjunto de programas para gerenciar os recursos disponíveis de um computador:

- [ ] Verdadeiro
- [ ] Falso

:heavy_check_mark: O sistema operacional tem como função:

- [ ] Gerenciar a memória física e virtual
- [ ] Permitir acesso direto aos periféricos
- [ ] Subcontratar o gerenciamento de tarefas para o processador
- [ ] Coletar informações sobre os programas utilizados ou em uso

:heavy_check_mark: Dentre essas personalidades, quais participaram do desenvolvimento do UNIX:

- [ ] Linus Torvalds
- [ ] Ken Thompson
- [ ] Lionel Richie
- [ ] Brian Kernighan
- [ ] Andrew Stuart Tanenbaum

:heavy_check_mark: A nacionalidade original de Linus Torvalds, criador do kernel Linux, é:

- [ ] Sueco
- [ ] Finlandês
- [ ] Norueguês
- [ ] Flamengo(Flemish)
- [ ] Francês

:heavy_check_mark: Quais das seguintes distribuições é a mais antiga:

- [ ] Debian
- [ ] Slackware
- [ ] RedHat
- [ ] Arch

:heavy_check_mark: O Kernel Linux é:

- [ ] Multitarefa
- [ ] Multi-usuário
- [ ] Multiprocessador
- [ ] Multi-core
- [ ] Multiplataforma
- [ ] Aberto

:heavy_check_mark: Um software livre é necessariamente de código aberto?

- [ ] Verdadeiro
- [ ] Falso

:heavy_check_mark: O software de código aberto é necessariamente gratuito?

- [ ] Verdadeiro
- [ ] Falso

:heavy_check_mark: Qual das seguintes opções não é um shell:

- [ ] Jason
- [ ] Jason-Bourne shell (jbsh)
- [ ] Bourne-Again shell (bash)
- [ ] C shell (csh)
- [ ] Korn shell (ksh)   
