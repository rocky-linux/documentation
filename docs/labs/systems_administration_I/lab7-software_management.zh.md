- - -
title: 管理并安装软件（实验7) author: Wale Soyinka contributors: Steven Spencer, tianci li tested on: 8.8 tags:
  - 实验练习
  - 软件管理
- - -

# 实验7：管理并安装软件

## 目标

完成本实验后，您将能够

- 查询软件包以获取信息
- 从二进制软件包安装软件
- 解决一些软件包基本的依赖关系问题
- 从源代码编译并安装软件

完成本实验的预计时间：90分钟

## 二进制文件和源文件

您当前在系统上安装的应用程序取决于几个因素。 主要因素取决于在操作系统安装期间选择的软件包组。 另一个因素取决于自系统使用以来对其所做的操作。

您会发现，作为系统管理员，您的日常任务之一是软件管理。 这通常涉及：

- 安装新软件
- 卸载软件
- 更新已安装的软件

软件可以使用多种方法安装在基于 Linux 的系统上。 您可以从源代码安装，也可以从预编译二进制文件安装。 后一种方法是迄今为止最简单的方法，但它也是最不可定制的。 当您从预编译的二进制文件进行安装时，大部分的工作都已经为您完成了，但即使这样，您仍然需要知道所需软件的名称和在何处找到所需软件。

几乎所有软件最初都是以 C 或 "C++" 编程语言源文件的形式进行提供。 源程序通常作为源文件的归档文件进行分发。 通常是 tar 结尾或 gzip结尾或 bzip2 结尾的文件。 这意味着它们是压缩的，或者是单个捆绑在一起的。

大多数开发者已经使他们的源代码符合 GNU 标准，从而更容易与他人共享。 这也意味着这些软件包可以在任何 UNIX 或类 UNIX 的系统（如 Linux）上编译。

RPM 是用于管理基于Red Hat 发行版（如Rocky Linux、Fedora、Red Hat Enterprise Linux(RHEL)、openSUSE、Mandrake等）上的应用程序包的底层工具。

用于管理 Linux 发行版软件的应用程序称为软件包管理器。 例如：

- Red Hat 软件包管理器 (`rpm`)。 软件包的后缀为 ".rpm"
- Debian 软件包管理系统(`dpkg`)。  软件包的后缀为 ".deb"

下面列出了 RPM 命令的一些常用命令行选项和语法：

**rpm**

用法：rpm [OPTION...]

**查询软件包**

```
查询选项（带上 -q 或 --query）：
  -c, --configfiles                  列出所有配置文件
  -d, --docfiles                  列出所有文档文件
  -L, --licensefiles                  列出所有许可证文件
  - A, --artifactfiles                  列出所有工件文件
      --dump                  转储基本文件信息
  -l, --list                  列出软件包中的文件
      --queryform=QUERYFORMAT      使用以下查询格式
  - s, --state                        显示列出文件的状态
```

**校验软件包**

```
校验选项（带上 -V 或 --verify）：
      --nofiledigest                 不校验文件摘要
      --nofiles                      不校验软件包中的文件
      --nodeps                       不校验软件包的依赖项
      --noscript                     不执行校验脚本
```

**安装、升级和移除程序包**

```
安装/升级/擦除选项：
      --allfiles                     安装所有的文件（甚至是那些可能会被跳过的配置文件）
  -e, --erase=<package>+             擦除（卸载）软件包
      --excludedocs                  不安装文档
      --excludepath=<path>           跳过以 <path> 开头的文件
      --force                        --replacepkgs --replacefiles  的缩写
  -F, --freshen=<packagefile>+       如果软件包已经安装，升级软件包
  -h, --hash                         软件包安装时列出哈希标记 (和 -v 一起使用效果更好)
      --noverify                     --ignorepayload --ignoresignature 的缩写
  -i, --install                      安装软件包
      --nodeps                       不验证软件包依赖
      --noscripts                    不执行软件包脚本
      --percent                      安装软件包时打印百分比
      --prefix=<dir>                 如果可重定位，便把软件包重定位到  <dir>
      --relocate=<old>=<new>         将文件从 <old> 重定位到 <new>
      --replacefiles                 忽略软件包之间的冲突文件
      --replacepkgs                  如果程序包已存在，则重新安装
      --test                         不真正安装，只是测试是否能被安装
  -U, --upgrade=<packagefile>+       升级软件包
      --reinstall=<packagefile>+     重新安装软件包
```

## 练习 1

### 安装、查询和卸载软件包

在本实验中，您将学习如何使用 RPM 系统，还将在您的系统上安装一个示例应用程序。

!!! tip "提示"

    您可以选择从哪里获取 Rocky Linux 软件包。 您可以从受信任的 [或不受信任的] 存储库手动下载它们。 您可以从发行版 ISO 中获取它们。 您可以使用诸如 nfs、git、https、ftp、smb、cifs 等协议从集中共享的位置获取它们。 如果您对此感到好奇，可以查看下面的官方网站，浏览适用的存储库以找到所需的软件包：
    
    https://download.rockylinux.org/pub/rocky/8.8/

#### 查询软件包信息

1. 要查看当前安装在本地系统上的所有软件包的列表，请键入以下命令：

    ```
    $ rpm -qa
    python3-gobject-base-*
    NetworkManager-*
    rocky-repos-*
    ...<OUTPUT TRUNCATED>...
    ```

    您应该会看到一个长长的列表。

2. 让我们更深入地研究一下，了解更多关于系统上安装的某个软件包的信息。 我们将检查 NetworkManager。 我们将使用 `rpm` 命令的 --query (-q) 和 --info (-i) 选项。 键入：

    ```
    $ rpm -qi NetworkManager
    Name        : NetworkManager
    Epoch       : 1
    ...<OUTPUT TRUNCATED>...
    ```

   这将包含大量的（元数据）信息！

3. 假设我们只对上一个命令的 Summary 字段感兴趣。 我们可以使用 rpm 的 --queryformat 选项来筛选从查询选项中返回的信息。

    例如，只查看 Summary 字段，键入：

    ```
    $ rpm -q --queryformat '%{summary}\n' NetworkManager
    ```

    字段名不区分大小写。

4. 查看已安装 NetworkManager 软件包的 Version 和 Summary 字段，键入：

    ```
    $ rpm -q --queryformat '%{version}  %{summary}\n' NetworkManager 
    ```

5. 键入以下命令以查看有关系统上安装的 bash 软件包的信息。

    ```
    $ rpm -qi bash
    ```

    !!! note "说明" 

     前面的练习是查询和使用系统上已安装的软件包。 在接下来的练习中，我们将开始使用尚未安装的软件包。 我们将使用 DNF 应用程序下载我们将在接下来的步骤中使用的软件包。

6. 首先确认 `wget` 应用程序尚未安装在系统上。 键入：

    ```
    $ rpm -q wget
    package wget is not installed
    ```

    我们的演示系统上似乎没有安装 `wget` 。

7. 从 Rocky Linux8.x 开始，`dnf download` 命令将允许您获得 `wget` 的最新 `rpm` 包。 键入：

    ```
    dnf download wget
    ```

8. 使用 `ls` 命令确保软件包已下载到您的当前目录。 键入：

    ```
    $ ls -lh wg*
    ```

9. 使用 `rpm` 命令查询有关下载的 wget-*.rpm 的信息。 键入：

    ```
    $ rpm -qip wget-*.rpm
    Name        : wget
    Architecture: x86_64
    Install Date: (not installed)
    Group       : Applications/Internet
    ...<TRUNCATED>...
    ```

10. 从上一步的输出信息来看，`wget` 软件包究竟包含了哪些内容？ 提示：您可以使用 rpm query 查询格式选项查看下载的软件包的 description 字段。

11.  如果您对 `wget files-.rpm` 软件包感兴趣，您可以通过键入以下内容列出软件包中包含的所有文件：

    ```
    $ rpm -qlp wget-*.rpm | head
    /etc/wgetrc
    /usr/bin/wget
    ...<TRUNCATED>...
    /usr/share/doc/wget/AUTHORS
    /usr/share/doc/wget/COPYING
    /usr/share/doc/wget/MAILING-LIST
    /usr/share/doc/wget/NEWS
    ```

12. 让我们查看 `/usr/share/doc/wget/AUTHORS` 文件的内容，该文件被列为 `wget` 软件包的一部分。 我们将使用 `cat` 命令进行查看。 键入：

    ```
    $ cat /usr/share/doc/wget/AUTHORS
    cat: /usr/share/doc/wget/AUTHORS: No such file or directory
    ```

    `wget` 尚未安装在我们的演示系统上！ 因此，我们无法查看与它一起打包的 AUTHORS 文件！

13. 查看系统中 *已经* 安装的另一个软件包（curl）的文件列表。 键入：

    ```
    $ rpm -ql curl
    /usr/bin/curl
    /usr/lib/.build-id
    /usr/lib/.build-id/fc
    ...<>...
    ```

    !!! note "说明"

     您会注意到，您不必在前面的命令中引用 `curl` 软件包的全名。 这是因为 `curl` 已经安装。

#### 关于软件包名称的扩展知识

* **完整包名**：当您从可信源(例如供应商网站、开发人员存储库)下载软件包时，下载文件的名称是完整包名，例如 -- htop-3.2.1-1.el8.x86_64.rpm。 使用 `rpm` 命令 安装/更新 此软件包时，该命令操作的对象必须是软件包的完整名称（或匹配的等效通配符），例如：

    ```
    $ rpm -ivh htop-3.2.1-1.el8.x86_64.rpm
    ```

    ```
    $ rpm -Uvh htop-3.2.1-1.*.rpm
    ```

    ```
    $ rpm -qip htop-3.*.rpm
    ```

    ```
    $ rpm -qlp wget-1.19.5-11.el8.x86_64.rpm
    ```


    软件包的完整名称遵循与以下类似的命名约定——`[Package_Name]-[Version]-[Release].[OS].[Arch].rpm` 或 `[Package_Name]-[Version]-[Release].[OS].[Arch].src.rpm`

* **包名**：因为 RPM 使用数据库来管理软件，所以一旦完成软件包的安装，数据库就会有相应的记录。 此时，`rpm` 命令的操作对象只需要键入包名。 例如：

    ```
    $ rpm -qi bash
    ```

    ```
    $ rpm -q systemd
    ```

    ```
    $ rpm -ql chrony
    ```



## 练习 2

### 软件包的完整性

1. 下载或最终得到一个损坏或受污染的文件是可能的。 验证您下载的 `wget` 软件包的完整性。 键入：

    ```
    $ rpm -K  wget-*.rpm
    wget-1.19.5-10.el8.x86_64.rpm: digests signatures OK
    ```

    输出中的 "Digest Signature OK" 消息显示软件包没有问题。

2. 让我们恶意地故意更改下载的软件包。 这可以通过在原始软件包中添加任何内容或从中删除某些内容来实现。  任何以原始软件包不希望的方式变更软件包的行为都会将其损坏。 我们将通过使用 echo 命令将字符串 "haha" 添加到软件包中来达到变更文件的目的。 键入：

    ```
    $ echo haha >> wget-1.19.5-10.el8.x86_64.rpm 
    ```

3. 现在尝试使用 rpm 的 -K 选项再次验证包的完整性。

    ```
    $ rpm -K  wget-*.rpm
    wget-1.19.5-10.el8.x86_64.rpm: DIGESTS SIGNATURES NOT OK
    ```

    现在的输出信息截然不同。 输出了 "Digest Signature Not OK"，明确警告您不应该尝试使用或安装该软件包。 它不再受到信任。

4. 使用 `rm` 命令删除损坏的 `wget` 软件包文件，并使用 `dnf`下载新的副本。 键入：

    ```
    $ rm wget-*.rpm  && dnf download wget
    ```

    再次检查新下载的软件包是否通过 RPM 完整性检查。

## 练习 3

### 安装软件包

当您尝试在系统上安装软件时，可能会遇到 "failed dependencies" 问题。 当使用低级 RPM 实用程序手动管理系统上的应用程序时，这种情况尤其常见。

例如，如果您尝试安装软件包"abc.rpm"，RPM 安装程序可能会输出一些失败的依赖项消息。 它可能会告诉您，软件包 "abc.rpm" 需要先安装另一个软件包 "xyz.rpm"。 依赖性问题的出现是因为软件应用程序几乎总是依赖于另一个软件或库。 如果系统上还没有所需的程序或共享库，那么在安装目标应用程序之前必须满足该先决条件。

低级 RPM 实用程序通常知道应用程序之间的相互依赖关系。 但它通常不知道如何或从哪里获得解决问题所需的应用程序或库。 换言之，RPM 知道 *what* 和 *how* ，但不具备回答 *where* 问题的内置能力。 这正是 `dnf`、`yum` 等工具的优势所在。

#### 安装软件包的步骤

在本练习中，您将尝试安装 `wget` 软件包（wget-*.rpm）。

1. 尝试安装 `wget` 应用程序。 使用 RPM 的 -ivh 命令行选项。 键入：

    ```
    $ rpm -ivh wget-*.rpm
    error: Failed dependencies:
        libmetalink.so.3()(64bit) is needed by wget-*
    ```

    马上出现一个依赖项问题！ 示例输出显示 `wget` 需要某种名为 "libmetalink.so.3" 的库文件

    !!! note "说明"

     根据上面测试的输出信息来看， wget-*.rpm 软件包要求 libmetalink-*.rpm 软件包被安装。 换言之，libmetalink 是安装 wget-*.rpm 的先决条件。 如果你完全知道自己在做什么，你可以使用 "nodeps" 选项强制安装 wget-*.rpm 软件包，但这通常是一种糟糕的做法。

2. RPM 向我们提供了关于缺失内容的有用提示。 您会记得 rpm 知道 what 和 how，但不一定知道 where。 让我们使用 `dnf` 实用程序来尝试找出提供缺失库的软件包名。 键入：

    ```
    $ dnf whatprovides libmetalink.so.3
    ...<TRUNCATED>...
    libmetalink-* : Metalink library written in C
    Repo        : baseos
    Matched from:
    Provide    : libmetalink.so.3
    ```

3. 从输出信息中，我们需要下载 `libmetalink` 软件包，它提供了缺失的库。 具体来说，我们需要 64 位版本的库。 让我们调用一个单独的实用程序 (`dnf`) 来帮助我们查找和下载演示的 64 位 (x86_64) 架构的软件包。 键入：

    ```
    dnf download --arch x86_64  libmetalink
    ```

4. 现在，您的工作目录中应该至少有 2 个 rpm 软件包。 使用 `ls` 命令来确认这一点。

5. 安装缺失的 `libmetalink` 依赖项。 键入：

    ```
    $ sudo rpm -ivh libmetalink-*.rpm
    ```

6. 依赖项被安装后，我们就可以重新实现最初的目标——安装 `wget` 软件包。 键入：

    ```
    $ sudo rpm -ivh wget-*.rpm
    ```

    !!! note "说明"

     RPM 支持事务。 在前面的练习中，我们可以执行单个 rpm 事务，其中包括我们想要安装的原始软件包以及它所依赖的所有软件包和库。 只需键入下面一行命令即可：

            ```
            $  rpm -Uvh  wget-*.rpm  libmetalink-*.rpm
            ```

7. 现在是关键时刻。 尝试在不带任何选项的情况下运行 `wget` 程序，以查看是否被安装。 键入：

    ```
    $ wget
    ```

8. 让我们看看 `wget` 的实际操作。 使用 `wget` 命令行从互联网上下载文件。 键入：

    ```
    wget  https://kernel.org
    ```

    这将从 kernel.org 网站下载默认的 index.html！

9. 使用 `rpm` 查看与 `wget` 应用程序一起提供的所有文件的列表。

10. 使用 `rpm` 查看随 `wget` 打包的任何文档。

11. 使用 `rpm` 查看与 `wget` 软件包一起安装的所有二进制文件的列表。

12. 您必须安装 `libmetalink` 软件包后才能安装 `wget` 。 尝试从命令行运行或执行 `libmetalink`。 键入：

    ```
    $ libmetalink
    -bash: libmetalink: command not found
    ```

    !!! attention "注意"

     怎么会这样？ 为什么你不能运行或执行 `libmetalink` ？


#### 通过 rpm 导入公钥

!!! tip "提示" 

    用于对 Rocky Linux 项目中使用的软件包进行签名的 GPG 密钥可以从各种来源获得，例如项目网站、ftp站点、分发媒体、本地源等。 如果 RL 系统的密钥环中缺少正确的密钥，您可以使用 `rpm` 的 `--import` 选项从您本地的 RL 系统导入 Rocky Linux 的公钥，方法是运行——`sudo  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial`

!!! question "问题"

    安装软件包时，`rpm -Uvh` 和 `rpm -ivh` 有什么区别。 
    请参阅 `rpm` 的手册页。

## 练习 4

### 卸载软件包

使用 Red Hat 的 包管理器（RPM），卸载软件包与安装软件包一样简单。

 在本练习中，您将尝试使用 `rpm` 从系统中卸载一些软件包。

#### 卸载软件包的步骤

1. 从您的系统中卸载 `libmetalink` 软件包。 键入：

    ```
    $ sudo rpm -e libmetalink
    ```

    !!! question "问题"

     请说明一下你为什么不能移除该软件包？


2. 使用 RPM 移除软件包干净而正确的方法是移除包及其依赖项。 要移除 `libmetalink` 软件包，我们还必须移除依赖于它的 `wget` 软件包。 键入：

    ```
    $ sudo rpm -e libmetalink wget
    ```

    !!! note "说明"

     如果您想破坏依赖于 libmetalink 的软件包并从您的系统中 "强制" 移除 libmetalink 软件包，你可以使用 rpm 的 `--nodeps` 选项，像这样：`$ sudo rpm  -e  --nodeps  libmetalink`。
    
     **i.** "nodeps" 选项表示无依赖。 即忽略所有依赖项。  
     **ii.** 以上只是向您展示如何从您的系统中强制移除软件包。 有时您需要这样做，但一般来说这 *不是好的做法*。   
     **iii.** 强制删除另一个已安装的 "abc" 软件包所依赖的 "xyz" 软件包，实际上会使软件包 "abc" 无法使用或某种程度上损坏。

## 练习 5

### DNF - 软件包管理器

DNF 是一个用于基于 RPM 的 Linux 发行版的软件包管理器。 它是广受欢迎的 YUM 实用程序的继承者。 DNF 保持与 YUM 的兼容性，且两个实用程序的命令行选项与语法非常相似。

DNF 是管理 Rocky Linux 等基于 RPM 软件的众多工具之一。 与 `rpm` 相比，这些更高级的工具有助于简化软件包的安装、卸载和查询。 需要注意的是，这些工具利用了 RPM 系统提供的底层框架。 这就是为什么了解如何使用 RPM 是有帮助的。

DNF（以及其他类似的工具）充当了 RPM 的某种封装器，并提供了 RPM 没有提供的附加功能。 DNF 知道如何处理软件包和库的依赖关系，也知道如何使用已配置的存储库自动解决大多数问题。

使用 `dnf` 实用程序的常见选项是：

```
    用法： dnf [options] COMMAND

    主要命令列表：

    alias                     列出或创建命令别名
    autoremove                移除最初作为依赖项安装的所有不需要的软件包
    check                     检查 packagedb 中的问题
    check-update              检查是否有可用的软件包升级
    clean                     移除缓存的数据
    deplist                   [deprecated, use repoquery --deplist] 列出软件包的依赖项以及哪些软件包提供这些依赖项
    distro-sync              将安装的软件包同步到最新的可用版本
    downgrade                 将软件包降级
    group                     显示或使用软件包组信息
    help                      显示有帮助的用法消息
    history                   显示或使用事务的历史记录
    info                      显示有关软件包或软件包组的详细信息
    install                  在系统上安装一个或多个软件包
    list                      列出一个或多组软件包
    makecache                 生成元数据缓存
    mark                      将已安装的软件包标记或取消标记为已由用户安装。
    module                    与模块交互。
    provides                  查找提供给定值的包
    reinstall                 重新安装软件包
    remove                    从系统中删除一个或多个软件包
    repolist                  显示已配置的软件存储库
    repoquery                 搜索与关键字匹配的软件包
    repository-packages       在给定存储库中的所有软件包上运行命令
    search                    搜索给定字符串的软件包详细信息
    shell                    运行交互式 DNF shell
    swap                     运行交互式 DNF mod 以删除和安装一个 spec
    updateinfo                显示有关软件包的参考建议
    upgrade                   升级系统上的一个或多个软件包
    upgrade-minimal           升级，但只能升级 "最新" 的匹配软件包，以修复影响系统的问题

```

#### 使用 `dnf` 进行软件包的安装

假设您已经从练习中卸载了 `wget` 实用程序，我们将在以下步骤中使用 DNF 来安装软件包。 我们之前通过 `rpm` 安装 `wget` 时需要的 2-3 个流程应该通过使用 `dnf` 减少到一个流程。 `dnf` 将静默解析所有依赖项。

1. 首先，让我们确保 `wget` 和 `libmetalink` 已从系统中卸载。 键入：

    ```
    $ sudo rpm -e wget libmetalink
    ```

    移除后，如果您尝试从 CLI 运行 `wget`，您会看到类似 *wget: command not found* 的消息。

2. 现在使用 dnf 安装 `wget`。 键入：

    ```
    $ sudo dnf -y install wget
    Dependencies resolved.
    ...<TRUNCATED>...
    Installed:
    libmetalink-*           wget-*
    Complete!
    ```

    !!! tip "提示"

     上面命令中使用的 "-y" 选项会取消 "[y/N]" 提示，以确认 `dnf` 即将执行的操作。 这意味着所有确认操作（或交互式应答）都将是 "yes"(y)。


3. DNF 提供了一个 "Environment Group" 选项，可以轻松地将新功能集添加到系统中。 要添加该功能，您通常需要单独安装几个软件包，但如果使用 `dnf`，您只需知道所需功能的名称或描述即可。 使用 `dnf` 来显示所有可用软件包组的列表。 键入：

    ```
    $ dnf group list
    ```

4. 我们对 "Development Tools" 软件包组/功能感兴趣。 让我们了解更多关于该软件包组的信息。 键入：

    ```
   $ dnf group info "Development Tools"
   ```

5. 稍后，我们将需要 "Development Tools" 软件包组中的一些程序。 使用 `dnf` 来安装 "Development Tools" 软件包组，运行：

    ```
    $ sudo dnf -y group install "Development Tools"
    ```

#### 使用 `dnf` 来卸载软件包


1. 使用 `dnf` 来卸载 `wget` 软件包，键入：

    ```
    $ sudo dnf -y remove wget
    ```

2. 使用 `dnf` 来确保软件包已经从系统中移除。 键入：

    ```
    $ sudo dnf -y remove wget
    ```

3. 尝试使用/运行 `wget`。 键入：

    ```
    $ wget
    ```

#### 使用 `dnf` 对软件包进行更新

DNF 可以检查并安装存储库中可用的各个软件包的最新版本。 它还可用于安装特定版本的软件包。

1. 将 list 选项与 `dnf` 一起使用，可以查看您系统可用的 `wget` 程序 的所有可用版本。 键入

    ```
    $ dnf list wget
    ```

2. 如果您只想查看软件包是否有可用的更新版本，请使用 `dnf` 的 check-update 选项。 例如，对于 `wget` 软件包，键入：

    ```
    $ dnf check-update wget
    ```

3. 现在列出系统上内核软件包的所有可用版本。 键入：

    ```
    $ sudo dnf list kernel
    ```

4. 现在检查已安装的内核软件包是否有更新的软件包。 键入：

    ```
    $ dnf  check-update kernel
    ```

5. 对软件包的更新可能是由于错误修复、新功能或安全补丁。 要查看内核软件包是否有任何与安全相关的更新，请键入以下内容：

    ```
    $ dnf  --security check-update kernel
    ```

#### 使用 `dnf` 进行系统更新

DNF 可用于检查并安装系统上已安装的所有软件包的最新版本。 定期检查并安装更新是系统管理的一个重要方面。

1. 要检查系统上当前安装的软件包是否有任何更新，请键入以下内容：

    ```
    $ dnf check-update
    ```

2. 要检查系统上安装的所有软件包是否有任何与安全相关的更新，请键入以下内容：

    ```
    $ dnf --security check-update
    ```

3. 要将系统中安装的所有软件包更新为发行版的最新版本，请运行：

    ```
    $ dnf -y check-update
    ```

## 练习 6

### 从源代码构建软件

所有软件/应用程序/软件包都源自人类可读的纯文本文件。 这些文件被统称为源代码。 安装在 Linux 发行版上的 RPM 软件包产生于源代码。

在本练习中，您将从其原始源文件下载、编译并安装示例程序。 为方便起见，源文件通常以称为 tar-ball（发音为 tar-point-gee-zee）的单个压缩文件的形式进行分发。

以下练习将基于久负盛名的 Hello 项目源代码。 `hello` 是一个用 C++ 编写的简单命令行应用程序，它除了在终端上打印 "hello" 之外什么也不做。 您可以在 [此处](http://www.gnu.org/software/hello/hello.html) 了解有关该项目的更多信息

#### 下载源文件

1. 使用 `curl` 下载 `hello` 应用程序的最新源代码。 让我们下载并将文件保存在 Downloads 文件夹中。

    https://ftp.gnu.org/gnu/hello/hello-2.12.tar.gz

#### 解压缩文件

1. 切换到本地计算机上下载 hello 源代码的目录。

2. 使用 `tar` 程序打开（解压缩）tarball。 键入：

    ```
    $ tar -xvzf hello-2.12.tar.gz
    hello-2.12/
    hello-2.12/NEWS
    hello-2.12/AUTHORS
    hello-2.12/hello.1
    hello-2.12/THANKS
    ...<TRUNCATED>...
    ```

3. 使用 `ls` 命令查看 pwd 的内容。

    在解压缩过程中，应该已经为您创建了一个名为 hello-2.12 的新目录。

4. 切换到该目录并列出其内容。 键入：

    ```
    $ cd hello-2.12 ; ls
    ```

5. 查看源代码中可能附带的任何特殊安装说明始终是一种最佳实践。 这些文件的名称通常是 INSTALL、README 等。

    使用分页程序打开 INSTALL 文件并阅读它。 键入：

    ```
    $ less INSTALL
    ```

    审阅完文件后，退出分页程序。

#### 配置软件包

大多数应用程序的功能都可以由用户启用或禁用。 这是访问源代码并从源代码进行安装的好处之一。 您可以控制应用程序拥有的可配置功能；这与接受软件包管理器从预编译二进制文件中安装的所有内容形成鲜明对比。

常规而言，用于配置软件的脚本通常被恰当地命名为 "configure"

1. 再次使用 `ls` 命令，以确保您的 pwd 中确实有一个名为 *configure* 的文件。

2. 要查看所有选项，您可以在 `hello` 程序类型中启用或禁用：

    ```
    $ ./configure --help
    ```

    !!! question

     从命令的输出来看，"--prefix" 选项的作用是什么？

3. 如果您对配置脚本提供的默认选项感到满意。 键入：

    ```
    $ ./configure
    ```

    !!! note "说明"

     希望配置阶段进行得很顺利，您可以进入编译阶段。

    如果在配置阶段出现了一些错误，则应该仔细查看输出的尾部，以查看错误的来源。 这些错误 *有时* 是一目了然的，而且很容易修复。 例如，你可能会看到这样的错误：

    configure: error: no acceptable C compiler found in $PATH

    上面的错误只是意味着您没有在系统上安装 C 编译器（例如 GCC），或者编译器安装在 PATH 变量之外的某个位置。

#### 编译软件包

您将在以下步骤中构建 hello 应用程序。 您之前使用 DNF 安装的 Development Tools 软件包组附带的一些程序正好派上用场。

1. 在运行 "configure" 脚本之后，使用 make 命令来编译软件包。 键入：

    ```
    $ make
    ...<OUTPUT TRUNCATED>...
    gcc  -g -O2   -o hello src/hello.o  ./lib/libhello.a
    make[2]: Leaving directory '/home/rocky/hello-2.12'
    make[1]: Leaving directory '/home/rocky/hello-2.12'
    ```

    如果一切顺利 -- 这个重要的 `make` 步骤将将有助于生成最终的 hello 应用程序二进制文件。

2. 再次列出当前工作目录中的文件。 您应该会在其中看到一些新创建的文件，包括 `hello` 程序。

#### 安装应用程序

在其他内务管理任务中，最后的安装步骤还包括将任何应用程序的二进制文件和库复制到正确的文件夹中。

1. 要安装 hello 应用程序，请运行 make install 命令。 键入：

    ```
    $ sudo make install
    ```

    这会将软件包安装到由默认 prefix（--prefix）参数指定的位置，该参数可能已在前面的 "configure" 脚本中使用过。 如果 --prefix 没有被设置，则将使用默认的 prefix ——`/usr/local/`。

#### 运行 hello 程序

1. 使用 `whereis` 命令查看 `hello` 程序在系统中的位置。 键入：

    ```
    $ whereis hello
    ```

2. 尝试运行 `hello` 应用程序以查看它的功能。 键入：

    ```
    $ hello
    ```

3. 使用 `--help` 选项再次运行 `hello`，以查看它可以执行的其他操作。

4. 使用 `sudo`，以超级用户身份再次运行 `hello`。 键入：

    ```
    $ sudo hello
    ```

    !!! tip "提示"

     使用普通用户对程序进行测试是一种很好的做法，以确保普通用户确实可以使用该程序。 二进制文件的权限可能设置不正确，因此只有超级用户才能使用这些程序。 当然，这是假设您确实希望普通用户能够使用该程序。

5. 这是这样。 这个实验已完成！

## 练习 7

### 安装软件包后检查文件完整性

在安装相关软件包后，在某些情况下，我们需要确定关联文件是否已被修改，以防止其他人恶意修改。

#### 文件校验

使用 `rpm` 命令的 "-V" 选项。

以时间同步程序 chrony 为例，说明其输出的含义。 假设您已经安装了chrony 并修改了配置文件（/etc/chrony.conf）

```
$ rpm -V chrony
S.5....T.  c /etc/chrony.conf
```

* **S.5....T.**：表示验证文件内容中的 9 个有用信息，未修改的用 "." 表示。 这 9 个有用的信息是：
  * S：文件大小是否已修改。
  * M：文件类型或文件权限（rwx）是否已修改。
  * 5：文件的 MD5 校验和是否已修改。
  * D：设备号是否已修改。
  * L：文件路径是否已修改。
  * U：文件所有者是否已修改。
  * G：文件所属组是否已修改。
  * T：文件的 mtime（修改时间）是否已修改。
  * P：程序功能是否已修改。

* **c**：表明对配置文件的修改。 它也可以是以下值：
  * d：文档文件
  * g：鬼文件。 极少能看到。
  * l：许可证文件。
  * r：自述文件。

* **/etc/chrony.conf**：表示修改后的文件路径。
