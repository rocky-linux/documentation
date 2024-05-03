---
title: bash - 脚本存根
author: Steven Spencer
contributors: Ezequiel Bruni
---

# bash - 脚本存根

在我之前受雇的地方，我们有一位精通多种语言的王牌程序员。 当你有关于如何用脚本完成某件事的问题时，他就是你要找的人。 他最终创建了一个小存根(Stub)——这是一个充满脚本示例的文件，你可以根据需要删除和编辑。 最终，我对这些示例掌握得足够好，不需要查看存根，但它是一个很好的学习工具，其他人可能会发现它很有用。

## 实际存根

存根有很好的文档记录，但请记住，这绝不是一个面面俱到的脚本！ 它还有更多的内容可以被添加。 如果**你**有很适合此存根的示例，请随意添加一些更改：

```
#!/bin/sh

# 通过export添加环境变量PATH的路径，您不必为这些路径中存在的命令输入完整路径：

export PATH="$PATH:/bin:/usr/bin:/usr/local/bin"

# 确定并保存程序目录的绝对路径。
# 注意！ 在bash中，' '表示字符串本身；但是" "有点不同， $、` `和 \ 分别表示调用变量值、引用命令和转义符
# 完成后，将与脚本位于同一目录中：

PGM=`basename $0`               # 程序名称
CDIR=`pwd`                  # 保存目录程序是从以下位置运行的

PDIR=`dirname $0`
cd $PDIR
PDIR=`pwd`

# 如果程序接受文件名作为参数，这将使我们回到开始的位置。
# (需要这样做，以便对使用相对路径的文件进行引用。):

cd $CDIR

# 如果脚本必须由特定用户运行，则使用此选项：

runby="root"
iam=`/usr/bin/id -un`
if [ $iam != "$runby" ]
then
    echo "$PGM : program must be run by user \"$runby\""
    exit
fi

# 检查是否缺少参数。
# 显示使用信息，如果缺少则退出。:

if [ "$1" = "" ]
then
    echo "$PGM : parameter 1 is required"
    echo "Usage: $PGM param-one"
    exit
fi

# 提示输入数据 (在这种情况下，默认为“N”的yes/no响应)：

/bin/echo -n "Do you wish to continue? [y/N] "
read yn
if [ "$yn" != "y" ] && [ "$yn" != "Y" ]
then
    echo "Cancelling..."
    exit;
fi

# 如果你的脚本一次只能运行一个副本，请使用这段代码。
# 检查lock file。  如果它不存在，则创建它。
# 如果确实存在，则显示错误消息并退出：

LOCKF="/tmp/${PGM}.lock"
if [ ! -e $LOCKF ]
then
    touch $LOCKF
else
    echo "$PGM: cannot continue -- lock file exists"
    echo
    echo "To continue make sure this program is not already running, then delete the"
    echo "lock file:"
    echo
    echo "    rm -f $LOCKF"
    echo
    echo "Aborting..."
    exit 0
fi

script_list=`ls customer/*`

for script in $script_list
do
    if [ $script != $PGM ]
    then
        echo "./${script}"
    fi
done

# Remove the lock file

rm -f $LOCKF
```

## 总结

脚本是系统管理员的好朋友。 能够在一个脚本中快速完成某些任务，简化流程的完成。 虽然这并不是一组详尽的脚本示例，但这个存根提供了一些常见的用法示例。
