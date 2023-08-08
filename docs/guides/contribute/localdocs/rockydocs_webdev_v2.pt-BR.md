---
title: Documentação Local - Podman
author: Wale Soyinka
contributors:
update: 13-Fev-2023
---

# Executando o site docs.rockylinux.org localmente para desenvolvimento web | Podman


Este documento passa pelas etapas de como recriar e rodar uma cópia local de todo o site docs.rockylinux.org em sua máquina local. Executar uma cópia local do site de documentação pode ser útil nos seguintes cenários:

* Você está interessado em aprender e contribuir para os aspectos de desenvolvimento web do site docs.rockylinux.org
* Você é um autor e gostaria de ver como seus documentos irão renderizar/olhar no site de documentos antes de contribuir


## Criar o ambiente de conteúdo

1. Certifique-se de atender aos pré-requisitos. Se não tiver, pule para a seção "\[Configurar os pré-requisitos\](##Configurar os pré-requisitos)" e volte aqui.

2. Altere o diretório de trabalho atual no seu sistema local para uma pasta onde você pretende escrever. Nós vamos nos referir a este diretório como `$ROCKYDOCS` no resto deste guia.  Para a nossa demonstração aqui, `$ROCKYDOCS` aponta para `$HOME/projects/rockydocs` em nosso sistema.

Crie $ROCKYDOCS se ele ainda não existir e mude seu diretório de trabalho para $ROCKYDOCS:

```
mkdir -p $HOME/projects/rockydocs
export ROCKYDOCS=${HOME}/projects/rockydocs
cd  $ROCKYDOCS
```

3. Certifique-se de que você tem o `git` instalado (`dnf -y install git`).  Quando estiver no $ROCKYDOCS use o git para clonar o repositório oficial de conteúdo da documentação Rocky. Digite:

```
git clone https://github.com/rocky-linux/documentation.git
```

Agora você terá uma pasta `$ROCKYDOCS/Document`. Esta pasta é um repositório git e está sob controle do git.

4. Também use o git para clonar o repositório oficial docs.rockylinux.org. Digite:

```
git clone https://github.com/rocky-linux/docs.rockylinux.org.git
```

Agora você terá uma pasta`$ROCKYDOCS/docs.rockylinux.org`. Esta pasta é onde você pode testar suas contribuições de desenvolvimento web.


## Crie e Inicie o ambiente de desenvolvimento web RockyDocs

5.  Certifique-se de que o podman está em execução na sua máquina local (você pode verificar com o `systemctl`). Teste com o comando:

```
systemctl enable --now podman.socket
```

6. Crie um novo arquivo `docker-compose.yml` com o seguinte conteúdo:

```
version: '2'
services:
  mkdocs:
    privileged: true
    image: rockylinux:9.1
    ports:
      - 8001:8001
    environment:
      PIP_NO_CACHE_DIR: "off"
      PIP_DISABLE_PIP_VERSION_CHECK: "on"
    volumes:
       - type: bind
         source: ./documentation
         target: /app/docs
       - type: bind
         source: ./docs.rockylinux.org
         target: /app/docs.rockylinux.org
    working_dir: /app
    command: bash -c "dnf install -y python3 pip git && \
       ln -sfn  /app/docs   docs.rockylinux.org/docs && \
       cd docs.rockylinux.org && \
       git config  --global user.name webmaster && \
       git config  --global user.email webmaster@rockylinux.org && \
       curl -SL https://raw.githubusercontent.com/rocky-linux/documentation-test/main/docs/labs/mike-plugin-changes.patch -o mike-plugin-changes.patch && \
       git apply --reverse --check mike-plugin-changes.patch && \
       /usr/bin/pip3 install --no-cache-dir -r requirements.txt && \
       /usr/local/bin/mike deploy -F mkdocs.yml 9.1 91alias && \
       /usr/local/bin/mike set-default 9.1 && \
       echo  All done && \
       /usr/local/bin/mike serve  -F mkdocs.yml -a  0.0.0.0:8001"

```

Salve o arquivo com o nome `docker-compose.yml` no seu diretório de trabalho $ROCKYDOCS.

Você também pode baixar rapidamente uma cópia do arquivo docker-compose.yml executando:

```
curl -SL https://raw.githubusercontent.com/rocky-linux/documentation-test/main/docs/labs/docker-compose-rockydocs.yml -o docker-compose.yml
```


7. Por fim, use o docker-compose para subir o serviço. Digite:

```
docker-compose  up
```


## Visualize o site local docs.rockylinux.org

8. Se por acaso você tiver um firewall em execução no seu sistema Rocky Linux, certifique-se que a porta 8001 esteja aberta. Digite:

```
firewall-cmd  --add-port=8001/tcp  --permanent
firewall-cmd  --reload
```

Com o contêiner em execução, agora você deve conseguir apontar seu navegador para a seguinte URL para ver sua cópia local do site:

http://localhost:8001

OU

http://<SERVER_IP>:8001




## Configurar os pré-requisitos

Instale e configure o podman e outras ferramentas executando:

```
sudo dnf -y install podman podman-docker git

sudo systemctl enable --now  podman.socket

```

Instale o docker-compose e torne-o executável. Digite:

```
curl -SL https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose

chmod 755 /usr/local/bin/docker-compose
```


Corrija as permissões no soquete docker. Digite:

```
sudo chmod 666 /var/run/docker.sock
```


### Notas:

* As instruções neste guia **NÃO** são um pré-requisito para a documentação de Autores/colaboradores de conteúdo do Rocky
* Todo o ambiente é executado em um contêiner Podman e então você precisará do Podman devidamente configurado no seu computador local
* O contêiner é construído sobre a imagem docker oficial do Linux 9.1 disponível aqui https://hub.docker.com/r/rockylinux/rockylinux
* O contêiner mantém o conteúdo da documentação separado do motor web (mkdocs)
* O contêiner inicia um servidor web local ouvindo na porta 8001. 
