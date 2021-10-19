---
title: 运行文档的本地副本
author: Wale Soyinka
contributors: tianci li, Steven Spencer
date: 2021-10-19
---

# 为Web开发和内容作者运行docs.rockylinux.org网站的本地副本

本文档介绍了如何在本地计算机上重新创建且运行整个docs.rockylinux.org网站的本地副本。**这是一项正在进行中的工作。**

在以下情况下，运行文档网站的本地副本可能很有用：

* 您有兴趣了解docs.rockylinux.org网站的Web开发方面并为其做出贡献
* 您是一名作者，在贡献文档之前，您希望查看文档在Docs网站上的外观呈现
* 您是一名Web开发人员，希望贡献或帮助维护docs.rockylinux.org网站


### 一些注意事项:

* 本指南中的说明**不是**Rocky文档作者或内容贡献者的必备条件
* 整个环境在Docker容器中运行，因此您需要在本地计算机上安装Docker引擎
* 该容器构建在官方的RockyLinux docker镜像之上，可从 https://hub.docker.com/r/rockylinux/rockylinux 获得
* 容器将文档内容(guides、books、images等)与Web引擎(Mkdocs)分开
* 容器会启动一个监听端口为8000的本地Web服务器，而8000端口将被转发到Docker主机上


## 创建内容环境

1. 将你本地系统中的当前工作目录改为你打算进行写作的文件夹，本指南的其余部分中，我们将该目录称为`$ROCKYDOCS`。在我们这里的演示中，`$ROCKYDOCS`指向我们演示系统上的`~/projects/rockydocs`。

    如果$ROCKYDOCS尚不存在，请创建它，然后键入：

    ```
    cd  $ROCKYDOCS
    ```

2. 请确保您已经安装了`git`(`dnf-y install git`)。在 $ROCKYDOCS 中，使用git克隆官方Rocky文档内容存储库（git repository）。
    ```
    git clone https://github.com/rocky-linux/documentation.git
    ```

    现在您将拥有一个`$ROCKYDOCS/Documentation`文件夹。该文件夹是一个git存储库（git repository），由git进行控制。


## 创建并启动RockyDocs的Web开发环境

3.  确保你的本地机器已经启动并运行了Docker（你可以用`systemctl`检查）

4. 从终端中执行以下操作：

    ```
    docker pull wsoyinka/rockydocs:latest
    ```

5. 检查以确保镜像下载成功

    ```
    docker image  ls
    ```

## 启动RockyDocs容器

1. 从rockydocs的镜像中启动一个容器。

    ```
    docker run -it --name rockydoc --rm \
        -p 8000:8000  \
        --mount type=bind,source="$(pwd)"/documentation,target=/documentation  \
        wsoyinka/rockydocs:latest

    ```


    或者，如果您愿意并且安装了`docker-compose`，您也可以创建名为`docker-compose.yml`的撰写文件，内容如下：

    ```
    version: "3.9"
    services:
    rockydocs:
        image: wsoyinka/rockydocs:latest
        volumes:
         - type: bind
          source: ./documentation
          target: /documentation
        container_name: rocky
     ports:
        - "8000:8000"

    ```

    将文件名为`docker-compose.yml`保存在$ROCKYDOCS工作目录中，并通过运行以下命令启动服务/容器：

    ```
    docker-compose  up
    ```


## 浏览本地的docs.rockylinux.org网站

容器启动且运行后，您现在应该可以将Web浏览器指向以下URL，以查看站点的本地副本：

http://localhost:8000
