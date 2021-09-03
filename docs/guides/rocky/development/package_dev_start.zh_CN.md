---
标题:  'Rocky Linux 开发工具（打包和开发人员入门指南）'
---


Rocky 开发工具（Devtools）指的是由 Rocky Linux 社区成员创建的一组自主开发的脚本和实用程序，用于帮助寻找、创建、去品牌、打补丁和构建随 Rocky Linux 操作系统分发的软件包。
Rocky 开发工具由 `rockyget`、`rockybuild`、`rockypatch` 和 `rockyprep` 组成。

在底层，Rocky 开发工具是一个包装器，用于运行一些用于各种包管理任务的自定义和传统程序。Rocky 开发工具高度依赖 [`srpmproc`](https://github.com/mstg/srpmproc)、`go`、`git` 和 `rpmbuild`。

安装和使用 Rocky 开发工具需要一个现有的基于 RPM 的现代 Linux 系统。

接下来演示开发工具的典型安装和使用场景。

## 1. 下载 Rocky Devtools

从以下 URL 下载 devtools 压缩源：

https://github.com/rocky-linux/devtools/archive/refs/heads/main.zip

此处使用 `curl` 命令：

```
curl -OJL https://github.com/rocky-linux/devtools/archive/refs/heads/main.zip
```

现在应该有一个名为  `devtools-main.zip` 的压缩归档文件。


## 2. 安装 Rocky Devtools

找到并解压缩刚刚下载的 devtools 归档文件。

此处将使用 `unzip` 命令：

```
unzip devtools-main.zip 
```

将您的工作目录更改为刚刚创建的新 devtool 源目录：

```
cd devtools-main
```

运行 `make` 以配置和编译 devtools：

```
make
```

安装 devtools：

```
sudo make install
```

## 3. 使用 Rocky Devtools (rockyget) 搜索和下载 Source RPMs (SRPMs)

安装后，查找和下载 SRPM 的主要程序是 `rockyget` 程序。

使用 `rockyget` 下载常用的 `sed` 包的 SRPM：

```
rockyget sed
```
首次运行 rockyget 时，它会自动创建一个目录结构，大致模仿 Rocky 构建服务器的仓库结构。例如，将自动创建 `~/rocky/rpms` 文件夹。

对于当前的 sed 示例，其源将存储在以下示例文件夹层次结构下：

```
~rocky/rpms/sed/
└── r8
    ├── SOURCES
    │   ├── sed-4.2.2-binary_copy_args.patch
    │   ├── sed-4.5.tar.xz
    │   ├── sedfaq.txt
    │   ├── sed-fuse.patch
    │   └── sed-selinux.patch
    └── SPECS
        └── sed.spec
```

### 提示 ：
有了原始源代码之后，现在可能是查看 SPECS 文件(`~rocky/rpms/sed/SPECS/specs.spec`)的好时机，以便在给定的包中查找潜在的去品牌机会。去品牌化可能包括更换上游图片/商标等。

### 提示
如果您正在寻找其他 Rocky 软件包进行构建和实验，您可以在[此处](https://kojidev.rockylinux.org/koji/builds?state=3&order=-build_id)  -  https://kojidev.rockylinux.org/koji/builds?state=3&order=-build_id 浏览 Rocky 自动构建环境中当前失败的软件包列表.


## 4. 使用 Rocky Devtools（rockybuild）为 Rocky OS 构建一个新包

在后台，`rockybuild` 调用 `rpmbuild` 和 `mock` 实用程序在 chroot 环境中为命令行上指定的应用程序构建源包。它依赖于通过 `rockyget` 命令自动下载的应用程序源和 RPM SPEC 文件。

使用 `rockybuild` 构建 sed 实用程序：

```
rockybuild sed
```

完成构建过程/步骤所需的时间取决于您尝试构建的应用程序的大小和复杂性。

在 `rockybuild` 运行结束时，类似于以下的输出表示构建成功完成。

```
..........
+ exit 0
Finish: rpmbuild sed-4.5-2.el8.src.rpm
Finish: build phase for sed-4.5-2.el8.src.rpm
INFO: Done(~/rocky/rpms/sed/r8/SRPMS/sed-4.5-2.el8.src.rpm) Config(baseos) 4 minutes 34 seconds
INFO: Results and/or logs in: /home/centos/rocky/builds/sed/r8
........
```


如果一切顺利，您应该在 `~/rocky/builds/sed/r8` 目录下找到一个 Rocky 就绪的 SRPM 文件。

`~/rocky/rpms/sed/r8/SRPMS/sed-4.5-2.el8.src.rpm`



## 5. 调试失败的包构建

之前的 rockybuild 过程将生成一些日志文件，可用于调试失败的应用程序构建。构建过程的结果和/或日志存储在 `~/rocky/builds/<PACKAGE NAME>/r8` 下。例如  `~/rocky/builds/sed/r8`：


``` 
~/rocky/builds/sed/r8
├── build.log
├── hw_info.log
├── installed_pkgs.log
├── root.log
├── sed-4.5-2.el8_3.src.rpm
├── sed-4.5-2.el8_3.x86_64.rpm
├── sed-debuginfo-4.5-2.el8_3.x86_64.rpm
├── sed-debugsource-4.5-2.el8_3.x86_64.rpm
└── state.log
```

搜索任何错误原因线索的主要文件是 build.log 和 root.log。build.log 文件应详细说明所有生成错误，root.log 文件将包含有关 chroot 环境设置和拆卸过程的信息。在其他条件相同的情况下，大多数构建调试/故障排除过程都可以使用 build.log 文件的内容执行。

