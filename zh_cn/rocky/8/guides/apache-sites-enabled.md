---
标题: 'Apache Web 服务器多站点设置'
---

# Apache Web 服务器多站点设置

Rocky Linux 提供了许多方法来设置网络站点。Apache 只是其中的一种方法，用于在单台服务器上进行多站点设置。尽管此方法是为多站点服务器设计的，但它也可以作为单个站点服务器的基本配置。 

历史事实：此服务器设置似乎是从基于 Debian 的系统开始的，但它完全适合于任何运行 Apache 的 Linux 操作系统。

## 准备工作

* 一台运行 Rocky Linux 的服务器
* 了解命令行和文本编辑器（选择您喜欢的编辑器，本示例使用 *vi*。）
    * 如果您想了解 vi 文本编辑器，[此处有一个简单教程](https://www.tutorialspoint.com/unix/unix-vi-editor.html)。
* 有关安装和运行 Web 服务的基本知识

## 安装 Apache

站点可能需要其他软件包。例如，几乎肯定需要 PHP，也可能需要一个数据库或其他包。从 Rocky Linux 仓库获取 PHP 与 httpd 的最新版本并安装。

谨记，您可能还需要模块，例如 php-bcmath 或 php-mysqlind。Web 应用程序规范应详细说明所需的模块。这些模块可以随时安装。现在将安装 httpd 和 PHP：

* 从命令行运行 `dnf install httpd php`

## 添加额外目录

本方法使用了两个额外目录，它们在当前系统上并不存在。在 */etc/httpd/* 中添加两个目录（sites-available 和 sites-enabled）。

* 从命令行处输入 `mkdir /etc/httpd/sites-available` 和 `mkdir /etc/httpd/sites-enabled`

* 还需要一个目录用来存放站点文件。它可以放在任何位置，但为了使目录井然有序，最好是创建一个名为 sub-domains 的目录。为简单起见，请将其放在 /var/www 中：`mkdir /var/www/sub-domains/`

## 配置

还需要在 httpd.conf 文件的末尾添加一行。为此，输入 `vi /etc/httpd/conf/httpd.conf` 并跳转到文件末尾，然后添加 `Include /etc/httpd/sites-enabled`。

实际配置文件位于 */etc/httpd/sites-available*，需在 */etc/httpd/sites-enabled* 中为它们创建符号链接。

**为什么要这么做？**

原因很简单。假设运行在同一服务器上的 10 个站点有不同的 IP 地址。站点 B 有一些重大更新，且必须更改该站点的配置。如果所做的更改有问题，当重新启动 httpd 以读取新更改时，httpd 将不会启动。

不仅 B 站点不会启动，其他站点也不会启动。使用此方法，您只需移除导致故障的站点的符号链接，然后重新启动 httpd 即可。它将重新开始工作，您可以开始工作，尝试修复损坏的站点配置。

### 站点配置

此方法的另一个好处是，它允许完全指定默认 httpd.conf 文件之外的所有内容。让默认的 httpd.conf 文件加载默认设置，并让站点配置执行其他所有操作。很好，对吧？再说一次，它使得排除损坏的站点配置故障变得非常容易。

现在，假设有一个 Wiki 站点，您需要一个配置文件，以通过 80 端口访问。如果站点使用 SSL（现在站点几乎都使用 SSL）提供服务，那么需要在同一文件中添加另一（几乎相同的）项，以便启用 443 端口。

因此，首先需要在 *sites-available* 中创建此配置文件：`vi /etc/httpd/sites-available/com.wiki.www`

配置文件的配置内容如下所示：

```apache
<VirtualHost *:80>
        ServerName www.wiki.com 
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/com.wiki.www/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/
        # ScriptAlias /cgi-bin/ /var/www/sub-domains/com.wiki.www/cgi-bin/

	CustomLog "/var/log/httpd/com.wiki.www-access_log" combined
	ErrorLog  "/var/log/httpd/com.wiki.www-error_log"

        <Directory /var/www/sub-domains/com.wiki.www/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```

创建文件后，需要写入（保存）该文件：`shift : wq`

在上面的示例中，wiki 站点是从 com.wiki.www 的 html 子目录加载的，这意味着在 /var/www（上面）中创建的路径需要一些额外的目录才能满足要求：

`mkdir -p /var/www/sub-domains/com.wiki.www/html`

这将使用单个命令创建整个路径。接下来将文件安装到该目录中，该目录将实际运行该站点。这些文件可能是由您或您下载的应用程序（在本例中为 Wiki）创建的。将文件复制到上面的路径：

`cp -Rf wiki_source/* /var/www/sub-domains/com.wiki.www/html/`

## 生效

注意，*httpd.conf* 文件在其末尾包含 */etc/httpd/sites-enabled*，因此，httpd 重新启动时，它将加载该 *sites-enabled* 目录中的所有配置文件。事实上，所有的配置文件都位于 *sites-available*。

这是设计使然，以便在 httpd 重新启动失败的情况下，可以轻松移除内容。因此，要启用配置文件，需要在 *sites-enabled* 中创建指向配置文件的符号链接，然后启动或重新启动 Web 服务。为此，使用以下命令：

`ln -s /etc/httpd/sites-available/com.wiki.www /etc/httpd/sites-enabled/`

这将在 *sites-enabled* 中创建指向配置文件的链接。

现在只需使用 `systemctl start httpd` 来启动 httpd。如果它已经在运行，则重新启动：`systemctl restart httpd`。假设网络服务重新启动，您现在可以在新站点上进行一些测试。
