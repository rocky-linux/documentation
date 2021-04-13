# 生成 SSL 密钥

# 准备工作

* 一个工作站和一台运行 Rocky Linux 的服务器。
* 在要生成私钥和 CSR 的机器上以及最终安装密钥和证书的服务器上安装 _OpenSSL_。
* 能够轻松地从命令行运行命令。
* 有关 SSL 和 OpenSSL 命令的知识。


# 简介

如今，每个网站都应使用 SSL（安全套接字协议层）证书运行。本文将指导您生成网站私钥，然后从中生成用于购买新证书的 CSR（证书签名请求）。

## 生成私钥

对于新手而言，SSL 私钥可以有不同的大小（以位为单位），其大小决定了破解的难易程度。

截至 2021 年，推荐的网站私钥大小仍为 2048 位。您可以使用更多位的密钥，但是将密钥大小从 2048 位增加一倍至 4096 位只会使安全性提高约 16%，但需要更多空间以存储密钥，并且在处理密钥时会导致 CPU 负载增高。

密钥位数过多不会获得任何显著的安全性，反而降低网站性能。
目前采用的密钥大小为 2048，始终关注当前推荐的密钥大小。

首先，请确保工作站和服务器上都安装了 OpenSSL：

`dnf install openssl`

如果未安装，则系统将安装它以及所有需要的依赖项。

示例使用的域是 ourownwiki.com。注意，您需要提前购买和注册域名。您可以通过多个“注册商”购买域名。

如果您没有运行自己的 DNS（域名系统），您可以使用 DNS 托管提供类似功能。DNS 将您的命名域转换为 Internet 可以理解的数字（IP地址、IPv4 或 IPv6）。这些 IP 地址将是网站的实际托管位置。

使用 openssl 生成密钥：

`openssl genrsa -des3 -out ourownwiki.com.key.pass 2048`

注意，将密钥命名为 .pass 扩展名。这是因为一旦执行此命令，它就会要求您输入密码。输入一个您可以记住的简单密码，因为很快就会移除此密码：

```
Enter pass phrase for ourownwiki.com.key.pass:
Verifying - Enter pass phrase for ourownwiki.com.key.pass:
```

接下来，移除该密码。这样做的原因是，如果不移除它，则每次 Web 服务器重新启动并加载密钥时，都需要输入该密码。

您可能不准备输入它，或者更糟的是，可能根本没有一个控制台可以输入它。现在将其移除以避免这些情况：

`openssl rsa -in ourownwiki.com.key.pass -out ourownwiki.com.key`

这将再次请求该密码从密钥中移除密码：

`Enter pass phrase for ourownwiki.com.key.pass:`

现在您已经第三次输入了密码，它已经从密钥文件中删除并另存为 ourownwiki.com.key。

## 生成 CSR

接下来，需要生成将用于购买证书的 CSR（证书签名请求）。

在生成 CSR 的过程中，系统将提示您输入一些信息。这些是证书的 X.509 属性。

其中一个提示是“公用名”。注意，此字段必须填写受 SSL 保护的服务器的完全限定域名。如果要保护的网站是 https://www.ourownwiki.com，然后在此提示下输入 www.ourownwiki.com：

`openssl req -new -key ourownwiki.com.key -out ourownwiki.com.csr`

它将产生以下对话：

`Country Name (2 letter code) [XX]:` 输入站点所在的国家/地区码（两个字符），例如“US”。
`State or Province Name (full name) []:` 输入所在州或省的全名，例如“Nebraska”。
`Locality Name (eg, city) [Default City]:` 输入所在城市的全名，例如“Omaha”。
`Organization Name (eg, company) [Default Company Ltd]:` 如果需要，您可以输入此域所属的组织，或者只需按“Enter”键即可跳过。
`Organizational Unit Name (eg, section) []:` 这将描述您的域所属的组织部门。同样，您只需按“Enter”键即可跳过。
`Common Name (eg, your name or your server's hostname) []:` 此处必须输入站点主机名，例如“www.ourownwiki.com”。
`Email Address []:` 此字段是可选的，您可以填写，也可以按“Enter”键跳过。

接下来，将要求您输入额外的属性，在以下两个属性中按“Enter”键跳过：

```
Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

现在，您应该已经生成了 CSR。

## 购买证书

每个证书供应商的流程基本相同。您购买 SSL 和期限（1 年或 2 年等）。然后提交 CSR。为此，您需要使用 `more` 命令，然后复制 CSR 文件的内容。

`more ourownwiki.com.csr`

它将显示以下内容：

```
-----BEGIN CERTIFICATE REQUEST-----
MIICrTCCAZUCAQAwaDELMAkGA1UEBhMCVVMxETAPBgNVBAgMCE5lYnJhc2thMQ4w
DAYDVQQHDAVPbWFoYTEcMBoGA1UECgwTRGVmYXVsdCBDb21wYW55IEx0ZDEYMBYG
A1UEAwwPd3d3Lm91cndpa2kuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAzwN02erkv9JDhpR8NsJ9eNSm/bLW/jNsZxlxOS3BSOOfQDdUkX0rAt4G
nFyBAHRAyxyRvxag13O1rVdKtxUv96E+v76KaEBtXTIZOEZgV1visZoih6U44xGr
wcrNnotMB5F/T92zYsK2+GG8F1p9zA8UxO5VrKRL7RL3DtcUwJ8GSbuudAnBhueT
nLlPk2LB6g6jCaYbSF7RcK9OL304varo6Uk0zSFprrg/Cze8lxNAxbFzfhOBIsTo
PafcA1E8f6y522L9Vaen21XsHyUuZBpooopNqXsG62dcpLy7sOXeBnta4LbHsTLb
hOmLrK8RummygUB8NKErpXz3RCEn6wIDAQABoAAwDQYJKoZIhvcNAQELBQADggEB
ABMLz/omVg8BbbKYNZRevsSZ80leyV8TXpmP+KaSAWhMcGm/bzx8aVAyqOMLR+rC
V7B68BqOdBtkj9g3u8IerKNRwv00pu2O/LOsOznphFrRQUaarQwAvKQKaNEG/UPL
gArmKdlDilXBcUFaC2WxBWgxXI6tsE40v4y1zJNZSWsCbjZj4Xj41SB7FemB4SAR
RhuaGAOwZnzJBjX60OVzDCZHsfokNobHiAZhRWldVNct0jfFmoRXb4EvWVcbLHnS
E5feDUgu+YQ6ThliTrj2VJRLOAv0Qsum5Yl1uF+FZF9x6/nU/SurUhoSYHQ6Co93
HFOltYOnfvz6tOEP39T/wMo=
-----END CERTIFICATE REQUEST-----
```

您需要复制所有内容，包括“BEGIN CERTIFICATE REQUEST”和“END CERTIFICATE REQUEST”行。 然后将它们粘贴到您购买证书的网站上的 CSR 字段中。

在颁发证书之前，您可能必须执行其他验证步骤，具体取决于域的所有权，所使用的注册商等。颁发时，它应与提供者提供的中间证书一起颁发，您还将在配置中使用该证书。

# 总结

生成用于购买网站证书的所有位和片段并不是非常困难，可以由系统管理员或网站管理员执行上述过程以完成该任务。
