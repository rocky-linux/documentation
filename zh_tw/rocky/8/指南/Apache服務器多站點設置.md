---
標題: 'Apache Web 服務器多站點設置'
---

# Apache Web 服務器多站點設置

Rocky Linux 提供了許多方法來設置網絡站點。Apache 只是其中的一種方法，用於在單臺服務器上進行多站點設置。儘管此方法是爲多站點服務器設計的，但它也可以作爲單個站點服務器的基本配置。 

歷史事實：此服務器設置似乎是從基於 Debian 的系統開始的，但它完全適合於任何運行 Apache 的 Linux 操作系統。

## 準備工作

* 一臺運行 Rocky Linux 的服務器
* 瞭解命令行和文本編輯器（選擇您喜歡的編輯器，本例使用 *vi*。）
    * 如果您想了解 vi 文本編輯器，[此處有一個簡單教程](https://www.tutorialspoint.com/unix/unix-vi-editor.html)。
* 有關安裝和運行 Web 服務的基本知識

## 安裝 Apache

站點可能需要其他軟件。例如，肯定需要 PHP，也可能需要一個數據庫或其他包。從 Rocky Linux 倉庫獲取 PHP 與 httpd 的最新版本並安裝。

謹記，您可能還需要php模塊，例如 php-bcmath 或 php-mysqlind。Web 應用程序規範應詳細說明所需的模塊。這些模塊可以隨時安裝。現在將安裝 httpd 和 PHP：

* 從命令行運行 `dnf install httpd php`

## 添加額外目錄

本方法使用了兩個額外目錄，它們在當前系統上並不存在。在 */etc/httpd/* 中添加兩個目錄（sites-available 和 sites-enabled）。

* 從命令行處輸入 `mkdir /etc/httpd/sites-available` 和 `mkdir /etc/httpd/sites-enabled`

* 還需要一個目錄用來存放站點文件。它可以放在任何位置，但爲了使目錄井然有序，最好是創建一個名爲 sub-domains 的目錄。爲簡單起見，請將其放在 /var/www 中：`mkdir /var/www/sub-domains/`

## 配置

還需要在 httpd.conf 文件的末尾添加一行。爲此，輸入 `vi /etc/httpd/conf/httpd.conf` 並跳轉到文件末尾，然後添加 `Include /etc/httpd/sites-enabled`。

實際配置文件位於 */etc/httpd/sites-available*，需在 */etc/httpd/sites-enabled* 中爲它們創建符號鏈接。

** 爲什麼要這麼做？**

原因很簡單。假設運行在同一服務器上的 10 個站點有不同的 IP 地址。站點 B 有一些重大更新，且必須更改該站點的配置。如果所做的更改有問題，當重新啓動 httpd 以讀取新更改時，httpd 將不會啓動。

不僅 B 站點不會啓動，其他站點也不會啓動。使用此方法，您只需移除導致故障的站點的符號鏈接，然後重新啓動 httpd 即可。它將重新開始工作，您可以開始工作，嘗試修復損壞的站點配置。

### 站點配置

此方法的另一個好處是，它允許完全指定默認 httpd.conf 文件之外的所有爲什麼要這麼做？**

原因很簡單。假設運行在同一服務器上的 10 個站點有不同的 IP 地址。站點 B 有一些重大更新，且必須更改該站點的配置。如果所做的更改有問題，當重新啓動 httpd 以讀取新更改時，httpd 將不會啓動。

不僅 B 站點不會啓動，其他站點也不會啓動。使用此方法，您只需移除導致故障的站點的符號鏈接，然後重新啓動 httpd 即可。它將重新開始工作，您可以開始工作，嘗試修復損壞的站點配置。

### 站點配置

此方法的另一個好處是，它允許完全指定默認 httpd.conf 文件之外的所有內容。讓默認的 httpd.conf 文件加載默認設置，並讓站點配置執行其他所有操作。很好，對吧？再說一次，它使得排除損壞的站點配置故障變得非常容易。

現在，假設有一個 Wiki 站點，您需要一個配置文件，以通過 80 端口訪問。如果站點使用 SSL（現在站點幾乎都使用 SSL）提供服務，那麼需要在同一文件中添加另一（幾乎相同的）項，以便啓用 443 端口。

因此，首先需要在 *sites-available* 中創建此配置文件：`vi /etc/httpd/sites-available/com.wiki.www`

配置文件的配置内容。讓默認的 httpd.conf 文件加載默認設置，並讓站點配置執行其他所有操作。很好，對吧？再說一次，它使得排除損壞的站點配置故障變得非常容易。

現在，假設有一個 Wiki 站點，您需要一個配置文件，以通過 80 端口訪問。如果站點使用 SSL（現在站點幾乎都使用 SSL）提供服務，那麼需要在同一文件中添加另一（幾乎相同的）項，以便啓用 443 端口。

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

在上面的示例中，wiki 站點是從 com.wiki.www 的 html 子目錄加載的，這意味着在 /var/www（上面）中創建的路徑需要一些額外的目錄才能滿足要求：

`mkdir -p /var/www/sub-domains/com.wiki.www/html`

這將使用單個命令創建整個路徑。接下來將文件安裝到該目錄中，該目錄將實際運行該站點。這些文件可能是由您或您下載的應用程序（在本例中爲 Wiki）創建的。將文件複製到上面的路徑：

`cp -Rf wiki_source/* /var/www/sub-domains/com.wiki.www/html/`

## 生效

注意，*httpd.conf* 文件在其末尾包含 */etc/httpd/sites-enabled*，因此，httpd 重新啓動時，它將加載該 *sites-enabled* 目錄中的所有配置文件。事實上，所有的配置文件都位於 *sites-available*。

這是設計使然，以便在 httpd 重新啓動失敗的情況下，可以輕鬆移除爲什麼要這麼做？**

原因很簡單。假設運行在同一服務器上的 10 個站點有不同的 IP 地址。站點 B 有一些重大更新，且必須更改該站點的配置。如果所做的更改有問題，當重新啓動 httpd 以讀取新更改時，httpd 將不會啓動。

不僅 B 站點不會啓動，其他站點也不會啓動。使用此方法，您只需移除導致故障的站點的符號鏈接，然後重新啓動 httpd 即可。它將重新開始工作，您可以開始工作，嘗試修復損壞的站點配置。

### 站點配置

此方法的另一個好處是，它允許完全指定默認 httpd.conf 文件之外的所有內容。讓默認的 httpd.conf 文件加載默認設置，並讓站點配置執行其他所有操作。很好，對吧？再說一次，它使得排除損壞的站點配置故障變得非常容易。

現在，假設有一個 Wiki 站點，您需要一個配置文件，以通過 80 端口訪問。如果站點使用 SSL（現在站點幾乎都使用 SSL）提供服務，那麼需要在同一文件中添加另一（幾乎相同的）項，以便啓用 443 端口。

因此，首先需要在 *sites-available* 中創建此配置文件：`vi /etc/httpd/sites-available/com.wiki.www`

配置文件的配置内容。因此，要啓用配置文件，需要在 *sites-enabled* 中創建指向配置文件的符號鏈接，然後啓動或重新啓動 Web 服務。爲此，使用以下命令：

`ln -s /etc/httpd/sites-available/com.wiki.www /etc/httpd/sites-enabled/`

這將在 *sites-enabled* 中創建指向配置文件的鏈接。

現在只需使用 `systemctl start httpd` 來啓動 httpd。如果它已經在運行，則重新啓動：`systemctl restart httpd`。假設網絡服務重新啓動，您現在可以在新站點上進行一些測試。
