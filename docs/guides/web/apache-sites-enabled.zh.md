---
标题: 'Apache Web 服务器多站点设置'
---

# Apache Web 服务器多站点设置

Rocky Linux 提供了许多方法来设置网络站点。Apache 只是在单台服务器上进行多站点设置的其中一种方法。尽管 Apache 是为多站点服务器设计的，但 Apache 也可以用于配置单站点服务器。

历史事实：这个服务器设置方法似乎源自 Debian 系发行版，但它完全适合于任何运行 Apache 的 Linux 操作系统。

## 准备工作

* 一台运行 Rocky Linux 的服务器
* 了解命令行和文本编辑器（本示例使用 *vi*，但您可以选择任意您喜欢的编辑器）
    * 如果您想了解 vi 文本编辑器，[此处有一个简单教程](https://www.tutorialspoint.com/unix/unix-vi-editor.html)。
* 有关安装和运行 Web 服务的基本知识

## 安装 Apache

站点可能需要其他软件包。例如，几乎肯定需要 PHP，也可能需要一个数据库或其他包。从 Rocky Linux 仓库获取 PHP 与 httpd 的最新版本并安装。

有时可能还需要额外安装 php-bcmath 或 php-mysqlind 等模块，Web 应用程序规范应该会详细说明所需的模块。接下来安装 httpd 和 PHP：

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

在上面的示例中，wiki 站点是从 com.wiki.www 的 html 子目录加载的，这意味着需要在上面提到的 /var/www 中创建额外的目录才能满足要求：

`mkdir -p /var/www/sub-domains/com.wiki.www/html`

这将使用单个命令创建整个路径。接下来将文件安装到该目录中，该目录将实际运行该站点。这些文件可能是由您或您下载的应用程序（在本例中为 Wiki）创建的。将文件复制到上面的路径：

`cp -Rf wiki_source/* /var/www/sub-domains/com.wiki.www/html/`

## 配置 https —— 使用 SSL 证书

如前所述，如今创建的每台 web 服务器都应该使用 SSL（也称为安全套接字层）运行。

此过程首先生成私钥和 CSR（表示证书签名请求），然后将 CSR 提交给证书颁发机构以购买 SSL 证书。生成这些密钥的过程有些复杂，因此它有自己的文档。

如果您不熟悉生成 SSL 密钥，请查看：[生成 SSL 密钥](../security/ssl_keys_https.md)

### 密钥和证书的位置

现在您已经拥有了密钥和证书文件，此时需要将它们按逻辑放置在 Web 服务器上的文件系统中。正如在上面示例配置文件中所看到的，将 Web 文件放置在 */var/www/sub-domains/com.ourownwiki.www/html* 中。

我们建议您将证书和密钥文件放在域（domain）中，而不是放在文档根（document root）目录中（在本例中是 *html* 文件夹）。

如果不这样做，证书和密钥有可能暴露在网络上。那会很糟糕！

我们建议的做法是，将在文档根目录之外为 SSL 文件创建新目录：

`mkdir -p /var/www/sub-domains/com.ourownwiki.www/ssl/{ssl.key,ssl.crt,ssl.csr}`

如果您不熟悉创建目录的“树（tree）”语法，那么上面所讲的是：

创建一个名为 ssl 的目录，然后在其中创建三个目录，分别为 ssl.key、ssl.crt 和 ssl.csr。

提前提醒一下：对于 web 服务器的功能来说，CSR 文件不必存储在树中。

如果您需要从其他供应商重新颁发证书，则最好保存 CSR 文件的副本。问题变成了在何处存储它以便您记住，将其存储在 web 站点的树中是合乎逻辑的。

假设已使用站点名称来命名 key、csr 和 crt（证书）文件，并且已将它们存储在  */root* 中，那么将它们复制到刚才创建的相应位置：

```bash
cp /root/com.wiki.www.key /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.key/
cp /root/com.wiki.www.csr /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.csr/
cp /root/com.wiki.www.crt /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.crt/
```

### 站点配置 —— https

一旦生成密钥并购买了 SSL 证书，现在就可以使用新密钥继续配置 web 站点。

首先，分析配置文件的开头。例如，即使仍希望监听 80 端口（标准 http）上的传入请求，但也不希望这些请求中的任何一个真正到达 80 端口。

希望请求转到 443 端口（或安全的 http，著名的 SSL）。80 端口的配置部分将变得最少：

```apache
<VirtualHost *:80>
        ServerName www.ourownwiki.com 
        ServerAdmin username@rockylinux.org
        Redirect / https://www.ourownwiki.com/
</VirtualHost>
```

这意味着要将任何常规 Web 请求发送到 https 配置。上面显示的 apache “Redirect”选项可以在所有测试完成后更改为“Redirect permanent”，此时站点应该就会按照您希望的方式运行。此处选择的“Redirect”是临时重定向。

搜索引擎将记住永久重定向，很快，从搜索引擎到您网站的所有流量都只会流向 443 端口（https），而无需先访问 80 端口（http）。

接下来，定义配置文件的 https 部分。为了清楚起见，此处重复了 http 部分，以表明这一切都发生在同一配置文件中：

```apache
<VirtualHost *:80>
        ServerName www.ourownwiki.com 
        ServerAdmin username@rockylinux.org
        Redirect / https://www.ourownwiki.com/
</VirtualHost>
<Virtual Host *:443>
        ServerName www.ourownwiki.com 
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/com.ourownwiki.www/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/
        # ScriptAlias /cgi-bin/ /var/www/sub-domains/com.ourownwiki.www/cgi-bin/

        CustomLog "/var/log/httpd/com.ourownwiki.www-access_log" combined
        ErrorLog  "/var/log/httpd/com.ourownwiki.www-error_log"

        SSLEngine on
        SSLProtocol all -SSLv2 -SSLv3 -TLSv1
        SSLHonorCipherOrder on
        SSLCipherSuite EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384
:EECDH+aRSA+SHA256:EECDH+aRSA+RC4:EECDH:EDH+aRSA:RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS

        SSLCertificateFile /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.crt/com.wiki.www.crt
        SSLCertificateKeyFile /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.key/com.wiki.www.key
        SSLCertificateChainFile /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.crt/your_providers_intermediate_certificate.crt

        <Directory /var/www/sub-domains/com.ourownwiki.www/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```

因此，在配置的常规部分之后，直到 SSL 部分结束，进一步分析此配置：

* SSLEngine on —— 表示使用 SSL。
* SSLProtocol all -SSLv2 -SSLv3 -TLSv1 —— 表示使用所有可用协议，但发现有漏洞的协议除外。您应该定期研究当前可接受的协议。
* SSLHonorCipherOrder on —— 这与下一行的相关密码套件一起使用，并表示按照给出的顺序对其进行处理。您应该定期检查要包含的密码套件。
* SSLCertificateFile —— 新购买和应用的证书文件及其位置。
* SSLCertificateKeyFile —— 创建证书签名请求时生成的密钥。
* SSLCertificateChainFile —— 来自证书提供商的证书，通常称为中间证书。

接下来，将所有内容全部上线，如果启动 Web 服务没有任何错误，并且如果转到您的网站显示没有错误的 https，那么您就可以开始使用。

## 生效

注意，*httpd.conf* 文件在其末尾包含 */etc/httpd/sites-enabled*，因此，httpd 重新启动时，它将加载该 *sites-enabled* 目录中的所有配置文件。事实上，所有的配置文件都位于 *sites-available*。

这是设计使然，以便在 httpd 重新启动失败的情况下，可以轻松移除内容。因此，要启用配置文件，需要在 *sites-enabled* 中创建指向配置文件的符号链接，然后启动或重新启动 Web 服务。为此，使用以下命令：

`ln -s /etc/httpd/sites-available/com.wiki.www /etc/httpd/sites-enabled/`

这将在 *sites-enabled* 中创建指向配置文件的链接。

现在只需使用 `systemctl start httpd` 来启动 httpd。如果它已经在运行，则重新启动：`systemctl restart httpd`。假设网络服务重新启动，您现在可以在新站点上进行一些测试。
