---
標題: 'Apache Web 服務器多網站點設置'
---

# Apache Web 服務器多網站點設置

Rocky Linux 提供了許多方法來設置網絡站點。Apache 只是其中的一種方法，用於在單臺服務器上進行多網站點設置。儘管此方法是爲多網站點服務器設計的，但它也可以作爲單個網站點服務器的基本配置。 

典故：此服務器設置從源於 Debian 的系統開始的，但它完全適合於任何可運行 Apache 的 Linux 操作系統。

## 準備工作

* 一臺運行 Rocky Linux 的服務器
* 瞭解命令行和文檔編輯器（選擇您喜歡的編輯器，本例使用 *vi*。）
    * 如果您想了解 vi 文檔編輯器，[此處有一個簡單英文版的教程](https://www.tutorialspoint.com/unix/unix-vi-editor.htm)。
* 有關安裝和運行 Web 服務的基本知識

## 安裝 Apache

網站點可能需要其他軟件。例如，肯定需要 PHP，也可能需要一個數據庫或其他包。從 Rocky Linux 倉庫獲取 PHP 與 httpd 的最新版本並安裝。

謹記，您可能還需要php模塊，例如 php-bcmath 或 php-mysqlind。Web 應用程序規範應詳細說明所需的模塊。這些模塊可以隨時安裝。現在將安裝 httpd 和 PHP：

* 從命令行執行 `dnf install httpd php`

## 添加額外目錄

本方法使用了兩個額外目錄，它們在當前系統上並不存在。在 */etc/httpd/* 中添加兩個目錄（sites-available 和 sites-enabled）。

* 從命令行處輸入 `mkdir /etc/httpd/sites-available` 和 `mkdir /etc/httpd/sites-enabled`

* 還需要一個目錄用來存放網站點文件。它可以放在任何位置，但爲了使目錄井然有序，最好是創建一個名爲 sub-domains 的目錄。爲簡單起見，請將其放在 /var/www 中：`mkdir /var/www/sub-domains/`

## httpd.conf 配置

還需要在 httpd.conf 文件的末尾添加一行。爲此，輸入 `vi /etc/httpd/conf/httpd.conf` 並跳轉到文件末尾，然後添加 `Include /etc/httpd/sites-enabled`。

實際配置文件位於 */etc/httpd/sites-available*，需在 */etc/httpd/sites-enabled* 中爲它們創建符號鏈接。

**爲什麼要這麼做？**

原因很簡單。假設運行在同一服務器上的 10 個網站點有不同的 IP 地址。網站點 B 有一些重大更新，且必須更改該網站點的配置。如果所做的更改有問題，當重新啓動 httpd 以讀取新更改時，httpd 將不會啓動。

不僅 B 網站點不會啓動，其他網站點也不會啓動。使用此方法，您只需移除導致故障的網站點的符號鏈接，然後重新啓動 httpd 即可。它將重新開始工作，您可以開始工作，嘗試修復損壞的網站點配置。

這樣就不會有全當機大壓力了, 顧客不大叫,上司不生氣.


### 網站點配置

此方法的另一個好處是，它允許完全指定默認 httpd.conf 文件之外的所有內容。讓默認的 httpd.conf 文件加載默認設置，並讓網站點配置執行其他所有操作。很好，對吧？再說一次，它使得排除損壞的網站點配置故障變得非常容易。

現在，假設有一個 Wiki 網站點，您需要一個配置文件，以通過 80 端口訪問。如果網站點使用 SSL（現在網站點幾乎都使用 SSL）提供服務，那麼需要在同一文件中添加另一（幾乎相同的）項，以便啓用 443 端口。

因此，首先需要在 *sites-available* 中創建此配置文件：`vi /etc/httpd/sites-available/com.wiki.www`

配置文件的配置内容。讓默認的 httpd.conf 文件加載默認設置，並讓網站點配置執行其他所有操作。很好，對吧？再說一次，它使得排除損壞的網站點配置故障變得非常容易。

現在，假設有一個 Wiki 網站點，您需要一個配置文件，以通過 80 端口訪問。如果網站點使用 SSL（現在站點幾乎都使用 SSL）提供服務，那麼需要在同一文件中添加另一（幾乎相同的）項，以便啓用 443 端口。

因此，首先需要在 *sites-available* 中創建此配置文件：`vi /etc/httpd/sites-available/com.wiki.www`

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

創建文件後，需要寫入（保存）該文件：`shift : wq`

在上面的示例中，wiki 網站點是從 com.wiki.www 的 html 子目錄加載的，這意味着在 /var/www（上面）中創建的路徑需要一些額外的目錄才能滿足要求：

`mkdir -p /var/www/sub-domains/com.wiki.www/html`

這將使用單個命令創建整個路徑。接下來將文件安裝到該目錄中，該目錄將實際運行該網站點。這些文件可能是由您或您下載的應用程序（在本例中爲 Wiki）創建的。將文件複製到上面的路徑：

`cp -Rf wiki_source/* /var/www/sub-domains/com.wiki.www/html/`

## 配置 https —— 使用 SSL 證書

如前所述，如今創建的每臺 web 服務器都應該使用 SSL（也稱爲安全套接字層）運行。

此過程首先生成私鑰和 CSR（表示證書籤名請求），然後將 CSR 提交給證書頒發機構以購買 SSL 證書。生成這些密鑰的過程有些複雜，因此它有自己的文檔。

如果您不熟悉生成 SSL 密鑰，請查看：[生成 SSL 密鑰](ssl_keys_https.md)

### 密鑰和證書的位置

現在您已經擁有了密鑰和證書文件，此時需要將它們按邏輯放置在 Web 服務器上的文件系統中。正如在上面示例配置文件中所看到的，將 Web 文件放置在 _/var/www/sub-domains/com.ourownwiki.www/html_ 中。

希望將證書和密鑰文件放在域（domain）中，而不是放在文檔根（document root）目錄中（在本例中是 _html_ 文件夾）。

絕不希望證書和密鑰有可能暴露在網絡上。那會很糟糕！

相反，將在文檔根目錄之外爲 SSL 文件創建一個新目錄結構：

`mkdir -p /var/www/sub-domains/com.ourownwiki.www/ssl/{ssl.key,ssl.crt,ssl.csr}`

如果您不熟悉創建目錄的“樹（tree）”語法，那麼上面所講的是：

創建一個名爲 ssl 的目錄，然後在其中創建三個目錄，分別爲 ssl.key、ssl.crt 和 ssl.csr。

提前提醒一下：對於 web 服務器的功能來說，CSR 文件不必存儲在樹中。

如果您需要從其他供應商重新頒發證書，則最好保存 CSR 文件的副本。問題變成了在何處存儲它以便您記住，將其存儲在 web 站點的樹中是合乎邏輯的。

假設已使用站點名稱來命名 key、csr 和 crt（證書）文件，並且已將它們存儲在  _/root_ 中，那麼將它們複製到剛纔創建的相應位置：

```
cp /root/com.wiki.www.key /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.key/
cp /root/com.wiki.www.csr /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.csr/
cp /root/com.wiki.www.crt /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.crt/
```

### 站點配置 —— https

一旦生成密鑰併購買了 SSL 證書，現在就可以使用新密鑰繼續配置 web 站點。

首先，分析配置文件的開頭。例如，即使仍希望監聽 80 端口（標準 http）上的傳入請求，但也不希望這些請求中的任何一個真正到達 80 端口。

希望請求轉到 443 端口（或安全的 http，著名的 SSL）。80 端口的配置部分將變得最少：

```
<VirtualHost *:80>
        ServerName www.ourownwiki.com
	        ServerAdmin username@rockylinux.org
		        Redirect / https://www.ourownwiki.com/
			</VirtualHost>
			```

這意味着要將任何常規 Web 請求發送到 https 配置。上面顯示的 apache “Redirect”選項可以在所有測試完成後更改爲“Redirect permanent”，您可以看到站點按照您希望的方式運行。此處選擇的“Redirect”是臨時重定向。

搜索引擎將記住永久重定向，很快，從搜索引擎到您網站的所有流量都只會流向 443 端口（https），而無需先訪問 80 端口（http）。

接下來，定義配置文件的https部分。爲了清楚起見，此處重複了 http 部分，以表明這一切都發生在同一配置文件中：

```
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

因此，在配置的常規部分之後，直到 SSL 部分結束，進一步分析此配置：

* SSLEngine on —— 表示使用 SSL。
* SSLProtocol all -SSLv2 -SSLv3 -TLSv1 —— 表示使用所有可用協議，但發現有漏洞的協議除外。您應該定期研究當前可接受的協議。
* SSLHonorCipherOrder on —— 這與下一行的相關密碼套件一起使用，並表示按照給出的順序對其進行處理。您應該定期檢查要包含的密碼套件。
* SSLCertificateFile —— 新購買和應用的證書文件及其位置。
* SSLCertificateKeyFile —— 創建證書籤名請求時生成的密鑰。
* SSLCertificateChainFile —— 來自證書提供商的證書，通常稱爲中間證書。

接下來，將所有內容全部上線，如果啓動 Web 服務沒有任何錯誤，並且如果轉到您的網站顯示沒有錯誤的 https，那麼您就可以開始使用。


## 啓動 httpd

注意，*httpd.conf* 文件在其末尾包含 */etc/httpd/sites-enabled*，因此，httpd 重新啓動時，它將加載該 *sites-enabled* 目錄中的所有配置文件。事實上，所有的配置文件都位於 *sites-available*。

這是設計使然，以便在 httpd 重新啓動失敗的情況下，可以輕鬆移除配置文件的配置内容。因此，要啓用配置文件，需要在 *sites-enabled* 中創建指向配置文件的符號鏈接，然後啓動或重新啓動 Web 服務。爲此，使用以下命令：

`ln -s /etc/httpd/sites-available/com.wiki.www /etc/httpd/sites-enabled/`

這將在 *sites-enabled* 中創建指向配置文件的鏈接。

現在只需使用 `systemctl start httpd` 來啓動 httpd。如果它已經在運行，則重新啓動：`systemctl restart httpd`。假設網絡服務重新啓動，您現在可以在新網站點上進行一些測試。
