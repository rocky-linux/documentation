---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - exercício do laboratório
---

# Lab. 1: Pré-requisitos

!!! info

    Este é um fork do original ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) escrito originalmente por Kelsey Hightower (GitHub: kelseyhightower). Ao contrário do original, que se baseia em distribuições semelhantes ao Debian para a arquitetura ARM64, este fork tem como alvo distribuições Enterprise Linux, como o Rocky Linux, que roda na arquitetura x86_64.

Neste laboratório, você revisará os requisitos de máquina necessários para seguir este tutorial.

## Máquinas Virtuais ou Físicas

Este tutorial requer quatro (4) máquinas virtuais ou físicas x86_64 executando o Rocky Linux 9.5 (os contêineres Incus ou LXD também devem funcionar). A tabela a seguir lista as quatro máquinas e seus requisitos de CPU, memória e armazenamento.

| Nome    | Descrição                    | CPU | RAM    | Armazenamento |
| ------- | ---------------------------- | --- | ------ | ------------- |
| jumpbox | Servidor de administração    | 1   | 512 MB | 10GB          |
| server  | Servidor Kubernetes          | 1   | 2GB    | 20GB          |
| node-0  | Nó de trabalho do Kubernetes | 1   | 2GB    | 20GB          |
| node-1  | Nó de trabalho do Kubernetes | 1   | 2GB    | 20GB          |

A maneira como você provisiona as máquinas fica por sua conta; o único requisito é que cada máquina atenda aos requisitos de sistema acima, incluindo as especificações da máquina e a versão do sistema operacional. Após provisionar todas as quatro máquinas, verifique os requisitos do sistema executando o comando `uname` em cada máquina:

```bash
uname -mov
```

Após executar o comando `uname`, você deverá ver a seguinte saída:

```text
#1 SMP PREEMPT_DYNAMIC Wed Feb 19 16:28:19 UTC 2025 x86_64 GNU/Linux
```

O `x86_64` na saída confirma que o sistema é uma arquitetura x86_64. Este deve ser o caso de vários sistemas baseados em AMD e Intel.

Next: [setting-up-the-jumpbox](lab2-jumpbox.md)
