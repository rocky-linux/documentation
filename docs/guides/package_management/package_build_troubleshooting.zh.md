## 首先熟悉 Mock 构建工具

熟悉 Mock 后，与软件包调试工作最相关的技术/简介页面如下：

https://wiki.rockylinux.org/en/team/development/Mock_Build_Howto。

我们正在使用“mock”程序来执行构建，就如使用 Rocky 基础设施一样。您应安装它并习惯使用它。本文提供入门指导，并说明希望实现的目标，以及为何必须按特定顺序构建所有包。

请仔细阅读本文，您可以尝试为 mock 提供 SRPM 或 2 并编译一些东西。

Mock 真的很棒，因为它是一个易调用的程序，它在 chroot 中构建整个系统来执行构建，然后进行清理。

如果您想要参考 Mock 配置文件以供使用，此处发布了一些参考文件（与测试包构建的“构建过程”相对应）：https://rocky.lowend.ninja/RockyDevel/mock_configs/。

熟悉 Mock（特别是深入了解其输出日志）后，将有一个失败包的列表，需要对其进行调查，并给出解释和/或修复。



## 简介 —— 目标

现在最需要帮助的地方，也是最简单的贡献方式，就是帮助解决包构建失败的问题。

我们正在将 CentOS 8.3 作为“练习”进行重构，这样就可以提前解决官方 Rocky 构建中出现的任何问题。我们正在记录在包中发现的任何错误以及如何修复它们（以使其构建）。当需要进行正式构建时，本文将对发布工程团队有所帮助。

## 帮助调试工作

熟悉 Mock 后，尤其是调试其输出，您就可以开始查看失败的包了。其中一些信息也在上面链接的 Mock HowTo 页面上。

在最新的构建过程失败页面（当前构建过程 10：https://wiki.rockylinux.org/en/team/development/Build_Order/Build_Pass_10_Failure）上查找失败的包。

确保包尚未查看和/或修复：https://wiki.rockylinux.org/en/team/development/Package_Error_Tracking。

让其他调试者知道您正在解决的包！我们不想重复工作。单击 chat.rockylinux.org (#dev/packaging 频道)并告知我们！

使用我们正在使用的最新配置（上面链接）设置您的 mock 程序。您可以使用它以与我们相同的方式尝试构建（使用外部依赖项、额外仓库等）。

调查错误：您可以使用自己的 mock，以及构建失败时的日志文件，位于此处：https://rocky.lowend.ninja/RockyDevel/MOCK_RAW/。

弄清楚缘由，以及如何修复它。它可以采用特殊 mock 设置的形式，也可以是添加到 program + specfile 的补丁。将您的调查结果报告给 #Dev/Packaging 频道，有人会将其记录在上面链接的 Wiki Package_Error_Tracking 页面上。

这样做可以缩小构建失败，并增加 Package_Error_Tracking 页面。如有必要，我们将为位于以下位置的不同软件包的补丁仓库提交构建修复：https://git.rockylinux.org/staging/patch。