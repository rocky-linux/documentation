---
title: rsync 配置文件
author: tianci li
update: 2026-11-12
---

# 概述

在本章中，您将学习如何配置Rsync配置文件。

## /etc/rsyncd.conf

!!! Note "说明"

    在 RL 8.10 中，软件包 "rsync-daemon" 可以在安装后释放此文件。

前面的文档描述了此文件中的一些参数项，如下表所示：

| 项                                         | 说明                                                   |
| ----------------------------------------- | ---------------------------------------------------- |
| address = 192.168.100.20                  | rsync 默认监听的 IP 地址                                    |
| port = 873                                | rsync 默认监听端口                                         |
| pid file = /var/run/rsyncd.pid            | 进程 PID 的文件位置                                         |
| log file = /var/log/rsyncd.log            | 日志文件的位置                                              |
| [share]                                   | 共享名称                                                 |
| comment = rsync                           | 备注或说明信息                                              |
| path = /rsync/                            | 指定目录路径                                               |
| read only = yes                           | yes 表示只读，no 表示可读可写                                   |
| dont compress = \*.gz \*.gz2 \*.zip | 哪些文件类型不会对其进行压缩                                       |
| auth users = li                           | 启用一个或多个虚拟用户，用英语逗号分隔                                  |
| secrets file = /etc/rsyncd_users.db       | 用于指定虚拟用户密码文件的位置，该文件必须以 .db 结尾。文件的内容格式为 "用户名:密码"，每行一个 |

还有其他一些参数项：

| 项                                   | 说明                                                                                                                                                                  |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| fake super = yes                    | yes 表示不需要 daemon 以 root 运行，就可以存储文件的完整属性                                                                                                                             |
| uid =                               | 使用基于 RSYNC 协议的身份验证时，虚拟用户（自定义虚拟用户）映射到的指定系统用户。如果未指定，则默认为 nobody 用户                                                                                                    |
| gid =                               | 使用基于 RSYNC 协议的身份验证时，虚拟组映射到的指定系统组。如果未指定，则默认为 nobody 组                                                                                                                |
| use chroot = yes                    | 数据传输前是否需要锁定根目录。出于安全原因，默认为 yes                                                                                                                                       |
| max connections = 4                 | 允许的最大连接数，默认值为 0，这意味着没有限制                                                                                                                                            |
| lock file = /var/run/rsyncd.lock    | 指定锁文件的位置                                                                                                                                                            |
| exclude = lost+found/               | 排除不需要传输的目录                                                                                                                                                          |
| transfer logging = yes              | 是否启用类似 ftp 的日志格式来记录 rsync 的上传和下载                                                                                                                                    |
| timeout = 900                       | 文件传输的超时时间。默认为 0，这意味着它永远不会超时                                                                                                                                         |
| ignore nonreadable = yes            | 是否忽略用户没有访问权限的文件                                                                                                                                                     |
| motd file = /etc/rsyncd/rsyncd.motd | 指定消息文件的路径。默认情况下，没有消息文件。消息文件的内容是指用户登录后显示的欢迎消息                                                                                                                        |
| hosts allow = 10.1.1.1/24           | 客户端访问控制白名单。您可以填写IP地址、网段、主机名等。使用空格分隔多个值。默认允许所有人访问                                                                                                                    |
| hosts deny = 10.1.1.20              | 客户端访问控制黑名单。如果 `hosts allow =` 和 `hosts deny =` 具有相同的匹配结果，则客户端最终无法访问。如果客户端既不在 `hosts allow =`范围内，也不在 `hosts deny =` 范围内，则允许此客户端访问。默认情况下，此参数项不存在                      |
| syslog facility = daemon            | 定义系统日志的级别。有这些值可填：auth、authpriv、cron、daemon、ftp、kern、lpr、mail、news、 security、syslog、user、uucp、 local0、local1、local2、local3、local4、local5、local6 和 local7。默认值是 daemon |

未提及的参数可以在 `man 5 rsyncd.conf` 中找到。

## 推荐的配置

```
uid = nobody
gid = nobody
address = 192.168.100.20
use chroot = yes
max connections = 10
syslog facility = daemon
pid file = /var/run/rsyncd.pid
log file = /var/log/rsyncd.log
lock file = /var/run/rsyncd.lock

[file]
comment = rsync
path = /rsync/
read only = no
dont compress = *.gz *.bz2 *.zip
auth users = li
secrets file = /etc/rsyncd_users.db
```
