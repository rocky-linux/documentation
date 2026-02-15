---
title: Migrando para novas imagens da Azure
author: Neil Hanlon
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - computação em nuvem
  - azure
  - microsoft azure
  - descontinuação
---

!!! info: "Imagens de Contas de Publicação Antiga Obsoletas A partir de abril de 2024"

```
O publicador de contas da Microsoft é um marketplace que permite que desenvolvedores publiquem suas ofertas para Microsoft AppSource ou Marketplace Azure. O RESF provê máquinas virtuais com Imagens Rocky Linux sobre 2 contas separadas publicadas na Azure; uma conta legado identificada como erockyenterprisesoftwarefoundationinc1653071250513 e uma nova conta oficial chamada 'resf'.
A imagem publicada sobre a conta publicada legado (erockyenterprisesoftwarefoundationinc1653071250513) foi marcada para obsolescência em 23 de abril de 2024, com janelas de 180 dias (6 meses) até que possam não ser mais usadas.

Para continuar usando Rocky Linux na Azure, você deve seguir este guia para migrar para a nova conta publicada ('resf') ou para a nova imagem de Galeria Comunitária.
```

# Guia de Migração: Migrando para a nova imagem Rocky Linux na Azure

Este guia provê etapas detalhadas para migrar sua maquina virtual Azure (VMs) da imagem Rocky Linux obsoleta para a nova imagem da conta publicada 'resf' ou usar a Galeria Comunitária. Seguir este guia garantira uma migração suave e com o mínimo de transtorno.

## Antes de começar

- Garanta que tenha um "backup" da sua VM. Mesmo o processo de migração não devendo afetar os dados, ter um "backup" é a melhor prática para qualquer mudança de sistema.
- Verifica se tem as permissões necessárias para criar a novas VMs e gerenciar já existentes na sua conta Azure.

## Etapa 1: Localize suas VMs existentes

Identifique a VMs implementada com a antiga imagem Rocky Linux. Você pode fazer isso filtrando suas VMs com o nome antigo da conta publicada:

```text
erockyenterprisesoftwarefoundationinc1653071250513`
```

## Etapa 2: Prepare a nova VM

1. **Vá** até o Marketplace Azure.
2. **Procure** pela nova imagem Rocky Linux com a conta 'resf' publicada ou acesse a Galeria Comunitária.
   - Caminhos Marketplace Atuais:
     - [Rocky Linux x86_64](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/resf.rockylinux-x86_64)
   - [Rocky Linux aarch64](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/resf.rockylinux-aarch64)
   - Instruções completas para acessar as imagens da Galeria Comunitária estão localizadas nesta: [nova postagem](https://rockylinux.org/news/rocky-on-azure-community-gallery/)
3. **Selecione** a versão desejada do Rocky Linux e **Crie a nova VM** Durante a configuração, você pode escolher o mesmo tamanho de VM e outras configurações semelhantes à sua VM existente para garantir compatibilidade.

## Etapa 3: Transferir dados

### Opção A: Usando gerenciador de disco Azure (recomendado pela simplicidade)

1. **Pare** sua VM existente.
2. **Desvincule** o disco do sistema operacional da sua VM existente.
3. **Vincule** o disco desvinculado para a nova VM como um disco de dados
4. **Inicie** sua nova VM. Se solicitado, você pode montar o antigo disco de OS e copiar dados para um novo disco.

### Opção B: Usando Ferramenta de Dados (Para ambientes complexos ou necessidades específicas)

1. **Selecione** a ferramenta de transferência de dados como a 'rsync' ou Armazenamento de Blob Azure para transferir arquivos.
2. **Transfira** dados da antiga VM para a nova VM. Isto pode incluir dados de aplicação, configurações e dados de usuários.

```bash
#Exemplo de comando rsync 
rsync -avzh /path/to/old_VM_data/ user@new_VM_IP:/path/to/new_VM_destination/
```

## Etapa 4: Reconfigura a nova VM

1. **Copie** qualquer configuração padrão ou adaptações que tenha na VM antiga para a nova VM, garantindo compatibilidade das configurações de ambientes preferidas.
2. **Teste** a nova VM para confirmar que a aplicação e serviços estão rodando como esperado.

## Etapa 5: Atualização dos registros de DNS (se aplicável)

Se você acessa sua VM através de um domínio específico, você deve atualizar seus registros de DNS para apontar para o novo endereço de IP das novas VM's.

## Etapa 6: Desative a antiga VM

Visto que confirmou que a nova VM esta funcionando corretamente e moveu todos os dados necessários, você pode **desativar e deletar** a antiga VM.

## Ultima etapa

- Valide que todos os serviços na nova VM estão funcionando como esperado.
- Monitore o desempenho e saúde da nova VM para garantir que atenda suas necessidades.

## Suporte

Caso encontre qualquer problema durante sua migração ou tenha dúvidas, o suporte esta sempre disponível. Visite [canais de suporte Rocky Linux](https://wiki.rockylinux.org/rocky/support/) para assistência.
