---
title: nmcli - 设置自动连接
author: wale soyinka
tags:
  - nmcli
---

# 修改 NetworkManager 配置文件的自动连接属性

在Rocky Linux 系统上，首先使用 nmcli 来查询和显示所有网络连接的自动连接属性的当前值。 输入：

```bash
nmcli -f name,autoconnect connection 
```

要更改网络连接的属性值，请使用 `nmcli connect` 的子命令 `modify`。 例如，要将 `ens3` 连接配置文件中的 autoconnect 属性值从 `no` 改为 `yes`，输入：

```bash
sudo nmcli con mod ens3 connection.autoconnect yes
```

## 命令说明

```bash
connection (con)       :  NetworkManager 连接对象 
modify (mod)           :  修改给定连接配置文件的一个或多个属性。
connection.autoconnect :  设置属性 (<setting>.<property>)
-f, --fields           :  指定要输出的字段
```

## 说明

这篇提示说明了修改现存的 NetworkManager 连接配置文件的方法。 当网络接口在新的Rocky Linux安装或系统更新后没有自动激活时，这很有用。 没有自动激活网络接口的原因往往是 autoconnect 属性值被设置为 `no`。 您可以使用 `nmcli` 命令快速将值更改为 `yes`。  
