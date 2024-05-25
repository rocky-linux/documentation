---
title: Aprendendo Linux com Rocky
---

<!-- markdownlint-disable MD025 MD007 -->

# Aprendendo Linux com Rocky

O Guia da Administração é uma coleção de Documentos de Ensino para Administradores do Sistema. Esses documentos podem ser usados por futuros administradores do sistema que tentam aprimorar seu aprendizado rapidamente, pelos atuais administradores do sistema que gostariam de se atualizar, ou por qualquer usuário do Linux que gostaria de aprender mais sobre o ambiente do Linux, comandos, processos e mais. Como todos os documentos desse tipo, ele será incrementado e atualizado ao longo do tempo.

Começaremos com uma introdução ao Linux, que envolve Linux, distribuições e todo o ecossistema em torno do nosso sistema operacional.

Comandos de Usuários contem comandos essenciais para se atualizar com Linux. Os usuários mais experientes devem também consultar o capítulo dedicado aos "comandos avançados".

O Editor de Texto VI merece seu próprio capítulo. Embora o Linux venha com muitos editores, VI é um dos mais poderosos. Outros comandos às vezes usam sintaxes idênticas(`sed` ou similares) aos comandos do VI . Portanto, saber algo sobre o VI, ou ao menos desmistificar suas funções essenciais (como abrir um arquivo, salvar, sair e salvar ou sair sem salvar), é muito importante. O usuário ficará mais confortável com as funções do VI à medida em que usar o editor. Uma alternativa seria usar o editor de texto nano que vem instalado por padrão no Rocky Linux. Embora não seja tão versátil, é simples de usar, direto e supre as necessidade do trabalho a ser feito.

Em seguida, podemos entrar no funcionamento mais profundo do Linux para compreender como o sistema aborda:

* Gerenciamento de Usuários
* Sistemas de Arquivos
* Gerenciamento de Processos

Backup e Restauração são informações essenciais para o Administrador de Sistema. O Linux vem com várias soluções para melhorar os backups (rsnapshot, lsyncd, etc.). É importante conhecer os componentes de backup essenciais que existem no sistema operacional. Neste capítulo vamos estudar duas ferramentas: `tar` e o menos conhecido `cpio`.

A Inicialização do Sistema também é uma leitura importante porque a gestão do sistema durante o processo de inicialização evoluiu significativamente nos últimos anos desde a chegada do systemd.

O capítulo final aborta a Gestão de Tarefas, Implementação da Rede e Gestão de Software incluindo a instalação.
