---
title: Conclusions
author: Antoine Le Morvan
contributors: Steven Spencer
tags:
  - tips and tricks
  - command line
---

## Now you are ready

Now that you have read this administrator's guide from cover to cover, you are
ready to administer Linux servers without fear.

Throughout these pages, you had an introduction to many advanced commands and
tricks. We have chosen to gather some of them here, along with a few of our own
favorite tips as a bonus.

These are the kinds of things that make the difference between a linux
administrator and a Linux Administrator.

!!! note

    None of the tips below are essential, and you can administer a server
    perfectly well without them. They are simply the small refinements that,
    over the years, make daily life on the command line more pleasant.

## The end-of-options marker `--`

A `--` marks the end of a command's options. This means that anything after is an
argument, even if it starts with a dash. In the following command, `--hard` is
not a long option but the name of the directory to create:

```bash
mkdir -p -- --hard
```

This is handy the day you have to deal with a file whose name starts with a dash
(`-file`), which the command would otherwise mistake for an option.

## Switching primary group with `newgrp`

The `newgrp` command starts a sub-shell in which your primary group becomes one
of your secondary groups. For example, if you belong to the `support` group:

```bash
newgrp support
```

starts a sub-shell in which your effective GID is that of the `support` group.
To leave it and return to your default GID, simply exit the sub-shell
(++ctrl+d++ or `exit`). Little known, this command is nonetheless very handy to
make the files you create belong to the right group.

## Giving a group a password with `gpasswd`

The `gpasswd` command allows for the assigning of a password to a group. What could that
possibly be useful for? Someone who knows the group password can `newgrp` into
that group without being a member of it. `gpasswd` also allows for the designation of group
administrators (`gpasswd -A`) who can add or remove members without needing root
privileges.

## Never run `chmod -R 644` on a directory tree

A common administration mistake is to run:

```bash
chmod -R 644 /target
```

which removes the execute (`x`) permission on every subdirectory and therefore
prevents anyone from navigating into them. It is better to target only the
files, with `find`:

```bash
find /target -type f -exec chmod 644 '{}' \;
```

!!! warning

    The trailing `\;` is mandatory. You can also use `+` instead, which batches
    the calls together and runs faster:

    ```bash
    find /target -type f -exec chmod 644 '{}' +
    ```

Even more elegant, the capital `X` only sets the execute bit on directories (and
files that already have it), in a single command:

```bash
chmod -R u=rwX,go=rX /target
```

## `tar` uses keys, not options

The `tar` command historically uses keys rather than options. Concretely,
`tar xvf` works where `tar -xvf` will not necessarily work on older systems.
Likewise, you used to have to specify the decompression format (a `j` for
bzip2, a `z` for gzip), whereas modern versions detect it automatically.

## The two integers at the end of `/etc/fstab` lines

At the end of each line in `/etc/fstab`, there are two integers, usually `0 0`.
The first one indicated whether you should include the filesystem in backups
(through the `dump` utility). The second one sets the order in which `fsck`
checks filesystems at boot, back when checking a filesystem could take a very
long time:

| value | meaning                            |
| ----- | ---------------------------------- |
| 0     | do not check at boot               |
| 1     | check first (reserved for `/`)     |
| 2     | check afterwards (other partitions)|

## Save and quit in vim with `:x`

In vim, `:x` saves and quits in two keystrokes instead of three for `:wq`. There
is a subtlety: unlike `:wq`, `:x` only writes the file if there is a modification,
so it does not needlessly touch the modification time, which can matter with
`make` or file watchers. In normal mode, ++shift+z++ ++shift+z++ does exactly the
same thing.

## A pipe only carries `stdout`

A `|` only connects the `stdout` of a command to the `stdin` of the next one.
The `stderr` stream does not go through the pipe by default. This can be
annoying for commands such as `ssh -V`, which print their version to the
`stderr` channel (channel 2).

To make `stderr` go through the pipe, redirect channel 2 onto channel 1:

```bash
ssh -V 2>&1 | cut -d',' -f1
```

!!! tip

    Watch out for the order of redirections. An output redirection must come
    **before** the `stderr` redirection, otherwise it will not do what you
    expect. This does **not** work as intended:

    ```bash
    ssh -V 2>&1 1>test.txt
    ```

    and should be written like this:

    ```bash
    ssh -V 1>test.txt 2>&1
    ```

This used to be the case as well with `java -version` (single dash; note that
the double-dash `java --version` introduced in Java 9 prints to `stdout`) or
`python2 --version`.

## Quick backups with brace expansion

Instead of retyping a filename, let the shell expand `{,.bak}` into two strings
(empty, then `.bak`):

```bash
cp file.conf{,.bak}
```

This creates `file.conf.bak`. The same principle allows for the creation of a whole tree at
once:

```bash
mkdir -p project/{src,bin,doc}
```

## History shortcuts for the last argument

Several shortcuts save you from retyping the last argument. `!$` re-injects the
last argument of the previous command:

```bash
mkdir -p /some/slightly/long/path && cd !$
```

++alt+"."++ does the same thing interactively and, pressed repeatedly, walks
back through the history of arguments. ++esc++ then ++"_"++ produces the same
`readline` function (`yank-last-arg`), with ++esc++ acting as the Meta key. As for
the famous:

```bash
sudo !!
```

it reruns the previous command prefixed with `sudo`, the reflex for when you
forgot it.

## Jump back with `cd -`

`cd -` takes you back to the previous directory, which is handy for going back
and forth between two folders. And `cd` on its own, with no argument, takes you
back to your home directory.

## `[` is actually a real program

The `[ ... ]` test you write inside an `if` is not magic shell syntax: `[` is a
full-fledged command (`/usr/bin/[`), just like `true` and `false`, which are
also real binaries.

## Group inheritance with the setgid bit

Setting the setgid bit on a directory forces group inheritance:

```bash
chmod g+s /share
```

From then on, any file created in `/share` belongs to the directory's group
rather than to the primary group of whoever creates it. This is the essential
trick for team shares, and it nicely complements the `newgrp` and `gpasswd` tips
above.

## Edit the current command line in your editor

++ctrl+x++ ++ctrl+e++ opens the command you are currently typing in your editor.
It is a lifesaver for one-liners that get out of hand: the shell opens the
current line in `$EDITOR` and runs it when you close the file. Much more
comfortable than editing a three-line command with the arrow keys.

## Make a file immutable with `chattr +i`

```bash
chattr +i /etc/resolv.conf
```

You can no longer modify the file or delete it, even by root, until you
remove the attribute (`chattr -i`). It is the perfect safeguard against an
unfortunate `rm`, or against the service that rewrites your `resolv.conf` on
every reboot.

## Turning a list into arguments with `xargs`

The `xargs` command turns a list received on `stdin` into arguments for another
command. With the `-I{}` placeholder, you build one command per line received:

```bash
ls *.log | xargs -I{} mv {} {}.old
```

You can parallelise the work with `-P` (here, four jobs at the same time):

```bash
cat urls.txt | xargs -P4 -I{} curl -sO {}
```

For filenames containing spaces, the safe combination is `find -print0` paired
with `xargs -0`, which separates entries on the null byte rather than on spaces:

```bash
find /target -type f -print0 | xargs -0 -I{} cp {} /backup/
```

As an almost-useless bonus, `xargs` with no command calls `echo` by default,
which turns it into a poor man's "trim": it strips leading and trailing spaces
and collapses multiple spaces into one.

## Conclusion

This short collection only scratches the surface. Linux rewards curiosity, and
every administrator eventually builds their own set of small habits that make
the command line feel like home. We hope a few of these will find their way into
yours.
