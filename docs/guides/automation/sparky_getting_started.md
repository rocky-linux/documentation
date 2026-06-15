---
title: Getting started with Sparky testing
author: Chris "Stack" Stackpole
contributors: Alexey Melezhik, Howard Van Der Wal
ai_contributors: Claude (claude-opus-4-8)
tested_with: 9.8
tags:
  - automation
  - raku
  - sparky
  - testing
---

**Knowledge**: :star:  
**Reading time**: 30 minutes

## AI usage

This document adheres to the [AI contribution policy found here.](../contribute/ai-contribution-policy.md) If you find any errors in the instructions, please let us know.

## What is this and why?

This guide explains how to install, configure, and run Sparky, so you can run the Rocky Linux Testing Team's automated use-case tests against Rocky Linux.

### Introduction to the core components of Rocky Linux testing

Perl is a programming language. Raku^2^ is a member of the Perl family (aka Perl 6). Sparrow^6^ is an automation framework built with Raku. Sparky^4^ is a continuous integration server and distributed task runner written in Raku that uses Sparrow.

### Why Sparky and Sparrow for Rocky Linux testing?

The goal for testing is to have more test coverage of common use cases that the Rocky Testing Team can verify on new Rocky Linux releases (both major and point releases). Additionally, there are two other goals:

1. As the tests can be rather simple Bash code, there is a desire for more system administrators to write automated tests about the things they care about. This provides a great opportunity for the Rocky Linux Community members to contribute to testing.
2. The tests can be used to verify documentation. This provides the Documentation Team an opportunity to catch (as an example) package breakages in a piece of documentation, before a user finds it.

The Venn diagram overlap of OpenQA, Kickstart tests, and Sparky is fairly minimal. While the Testing Team had hopes to integrate most of the documentation into OpenQA or the Kickstart tests, the process was becoming complicated. Sparky provides an automation framework tool that is much easier for the Rocky Linux Community to contribute to.

## Prerequisites

- A Rocky Linux 9 base install on x86_64 or aarch64. The RISC-V instructions assume Rocky Linux 10.
- Administrative access through `sudo` to install packages and open a firewall port.
- Optional: you can run this inside a virtual machine as long as the host provides QEMU pass through for nested virtualization. That setup is not covered in this guide, but it helps if you are doing a lot of configuration testing and you need to restart or reset quickly.

## Install

This guide should be everything you need to get started running the Rocky test scripts with Sparky.

### Install dependencies

```bash
sudo dnf install -y wget tar perl xorriso bash-completion qemu-kvm vim sqlite git openssl-devel rsync tmux genisoimage
```

### Install Raku x86_64

There are two ways and the recommended one is from the package repository:

#### From the package repo

```bash
sudo rpm --import 'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/gpg.0DD4CA7EB1C6CC6B.key'
sudo curl -1sLf 'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/config.rpm.txt?distro=el&codename=9' > /tmp/nxadm-pkgs-rakudo-pkg.repo
sudo dnf config-manager --add-repo '/tmp/nxadm-pkgs-rakudo-pkg.repo'
sudo dnf --refresh -y install rakudo-pkg
/opt/rakudo-pkg/bin/add-rakudo-to-path
source ~/.bash_profile
# Verify raku is in the path
which raku
# Verify zef is in the path - if it is, skip to the next section
which zef
/opt/rakudo-pkg/bin/install-zef
source ~/.bash_profile
```

You will be prompted to add `.raku/bin` to your path. You can do this via the following command:

```bash
tee -a ~/.profile << 'EOF'
export PATH=~/.raku/bin:$PATH
EOF
```

After that, run `source` to continue using the binary in your running session with:

```bash
source ~/.bash_profile
```

#### Pulling down and running a remote script

```bash
curl https://rakubrew.org/install-on-perl.sh | sh
echo 'eval "$(~/.rakubrew/bin/rakubrew init Bash)"' >> ~/.bashrc
eval "$(~/.rakubrew/bin/rakubrew init Bash)"
rakubrew download moar-2026.02
```

### Install Raku on aarch64

There are not yet package repositories available for aarch64, thus manual compiling is necessary at this time:

```bash
sudo dnf -y group install "Development Tools"
curl https://rakubrew.org/install-on-perl.sh | sh
echo 'eval "$(~/.rakubrew/bin/rakubrew init Bash)"' >> ~/.bashrc
eval "$(~/.rakubrew/bin/rakubrew init Bash)"
rakubrew build moar-2026.02
rakubrew build zef
```

### Install Raku on RISC-V

There are not yet package repos for RISC-V, thus manual compiling is necessary at this time. Additionally, there are changes for the architecture that need to be configured.

!!! warning

    RISC-V support is still in early testing.

```bash
sudo dnf -y group install "Development Tools"
sudo dnf -y install libffi-devel
curl https://rakubrew.org/install-on-perl.sh | sh
echo 'eval "$(~/.rakubrew/bin/rakubrew init Bash)"' >> ~/.bashrc
eval "$(~/.rakubrew/bin/rakubrew init Bash)"
# This is almost certainly going to fail at this stage with failure of MoarVM and dyncall. The next steps fix it
rakubrew build moar-2026.02
cd ~/.rakubrew/versions/moar-2026.02/nqp/MoarVM/
/usr/bin/perl Configure.pl --optimize --git-cache-dir=~/.rakubrew/git_reference --prefix=~/.rakubrew/versions/moar-2025.08/install --make-install --has-libffi
# This should find a working MoarVM and continue the compilation
rakubrew build moar-2026.02
rakubrew build zef
```

Now test that it works:

```bash
raku -v
```

## Clone Sparky

There is a high chance that something will fail a test in this `zef install .` command.

If the error is a missing package, try to install the missing package.

The install above should cover all the dependencies you need, but things could change regarding package availability for example.

You might need to do a `dnf provides */missing.so` search. If the error is about a failed test, then try running this:

```bash
zef install --/test .
```

Due to a known issue, the three stage install process outlined below works the most reliably:

```bash
mkdir ~/Code
cd ~/Code
git clone https://github.com/melezhik/sparky.git
cd sparky
zef install DBIish --/test
zef install cro --deps-only
zef install cro
zef install .
```

### Install Sparky

Only run this command after `zef install .` has finished:

```bash
raku db-init.raku
```

However, do note—sometimes you might get an error similar to what is described below:

`⚠ sparky DBDish::SQLite: Error: no such table: builds (1)`

This could be because of a corrupt db (for example, you copied the db from another user's repository, or a test went really bad). That command will reset the db.

### Install Sparky Job API

Run the following command:

```bash
zef install Sparky::JobApi
```

If successful, you should see the following output:

```bash
All candidates are currently installed
```

## Configure

### Firewall

Ensure the firewall allows port 4000:

```bash
sudo firewall-cmd --add-port=4000/tcp --permanent
sudo firewall-cmd --reload
```

## Project setup

Now it is time to load some projects.

### Code repo prep

```bash
cd ~/Code
git clone https://git.resf.org/testing/Sparky_Rocky
cd Sparky_Rocky
bash scripts/sync_project.sh
```

This is the expected output:

```text
Creating project folder in ~/.sparky
Checking for ~/sparky.yaml
Creating API Key in ~/sparky.yaml
Checking for ~/.sparky/templates/vars.yaml
Copying project files
```

#### A note about the API key

This can and should be a random string. This needs to be on any system where the Sparky server is installed and run—in this demo so far, that would be just your host. This key should have been generated from the above script and can be located in `~/sparky.yaml`

### Download images

There is no need to download images manually. The available images are defined in the `qemu_image` list in your `~/.sparky/templates/vars.yaml` file, and Sparky downloads the one you pick when a job runs. By default the list ships Rocky Linux 9 x86_64, Rocky Linux 10 x86_64, and Rocky Linux 10 aarch64.

To add another image, or change the download URL for an existing one, edit that list (if you are not sure how to use the `nano` editor, here is the man page^1^):

```bash
nano ~/.sparky/templates/vars.yaml
```

Under `vars` -> `qemu_test`, each `qemu_image` entry is a name and a download URL joined by a colon (`name:url`):

```yaml
vars:
  qemu_test:
    qemu_image:
      - "Rocky-9-GenericCloud:https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
      - "Rocky-10-GenericCloud:https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-GenericCloud-Base.latest.x86_64.qcow2"
      - "Rocky-10-GenericCloud-Aarch:https://dl.rockylinux.org/pub/rocky/10/images/aarch64/Rocky-10-GenericCloud-Base.latest.aarch64.qcow2"
```

For example, to add a Rocky Linux 8 image, append another line:

```yaml
      - "Rocky-8-GenericCloud:https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-GenericCloud-Base.latest.x86_64.qcow2"
```

Refresh the web interface and the new image appears in the `version` drop down on the job page. Select it and start a job with the `bootstrap` checkbox enabled. Sparky downloads the image the first time and reuses the cached copy after that.

### Configure Sparky

The `vars.yaml` file holds a lot of important variables. The template should have been created from the above `sync_project.sh` script. Please verify your `~/.sparky/templates/vars.yaml` file. The template can be found under the examples folder in the Sparky_Rocky^5^ project.

#### Verify QEMU binary

Your QEMU binary may be different. And you might have to specify a machine type. This is a simple guide to help you find your QEMU binary but not an exhaustive list. Once you know the binary/path - update it in the `vars.yaml` file.

```bash
which qemu-kvm
ls -lh /usr/libexec/qemu*
# If the QEMU binary is not in your path, here are a few ways to ensure it is. Try them all until you find one that works.
alias qemu-kvm=/usr/libexec/qemu-kvm
echo 'alias qemu-kvm=/usr/libexec/qemu-kvm' >> ~/.bash_profile
mkdir ~/bin && ln -s /usr/libexec/qemu-kvm ~/bin/qemu-kvm
```

#### Verify QEMU machine

After you find the QEMU binary, you need to know what machine types your system supports. Pick the best one from the list generated by the following command:

```bash
qemu-kvm -machine help
```

This is an example output from a Rocky Linux 9 x86_64 machine:

```bash
[howard@rocky9 ~]$ qemu-kvm -machine help
Supported machines are:
pc                   RHEL 7.6.0 PC (i440FX + PIIX, 1996) (alias of pc-i440fx-rhel7.6.0)
pc-i440fx-rhel7.6.0  RHEL 7.6.0 PC (i440FX + PIIX, 1996) (default) (deprecated)
q35                  RHEL-9.8.0 PC (Q35 + ICH9, 2009) (alias of pc-q35-rhel9.8.0)
pc-q35-rhel9.8.0     RHEL-9.8.0 PC (Q35 + ICH9, 2009)
pc-q35-rhel9.6.0     RHEL-9.6.0 PC (Q35 + ICH9, 2009)
pc-q35-rhel9.4.0     RHEL-9.4.0 PC (Q35 + ICH9, 2009)
pc-q35-rhel9.2.0     RHEL-9.2.0 PC (Q35 + ICH9, 2009)
pc-q35-rhel9.0.0     RHEL-9.0.0 PC (Q35 + ICH9, 2009)
pc-q35-rhel8.6.0     RHEL-8.6.0 PC (Q35 + ICH9, 2009) (deprecated)
pc-q35-rhel8.5.0     RHEL-8.5.0 PC (Q35 + ICH9, 2009) (deprecated)
pc-q35-rhel8.4.0     RHEL-8.4.0 PC (Q35 + ICH9, 2009) (deprecated)
pc-q35-rhel8.3.0     RHEL-8.3.0 PC (Q35 + ICH9, 2009) (deprecated)
pc-q35-rhel8.2.0     RHEL-8.2.0 PC (Q35 + ICH9, 2009) (deprecated)
pc-q35-rhel8.1.0     RHEL-8.1.0 PC (Q35 + ICH9, 2009) (deprecated)
pc-q35-rhel8.0.0     RHEL-8.0.0 PC (Q35 + ICH9, 2009) (deprecated)
pc-q35-rhel7.6.0     RHEL-7.6.0 PC (Q35 + ICH9, 2009) (deprecated)
none                 empty machine
```

Then open the `~/.sparky/templates/vars.yaml` config in your text editor.

You will observe a similar code block as below:

```yaml
    qemu:
      binary: qemu-kvm
      #binary: qemu-system-x86_64
      machine: ""
      #machine: pc-q35-rhel9.4.0
```

From the above example, you see that it is not using the latest machine setting, which is `pc-q35-rhel9.8.0`.

In this case, you would need to set the `vars.yaml` configuration like so:

```yaml
    qemu:
      binary: qemu-kvm
      #binary: qemu-system-x86_64
      machine: "pc-q35-rhel9.8.0"
      #machine: pc-q35-rhel9.4.0
```

#### Verify SSH

If you do not have an SSH key, run the following command:

```bash
ssh-keygen -t ed25519
```

Press "enter" to accept all of the defaults.

Then verify your key path with `ls -l ~/.ssh/`. It will look like the output below:

```bash
[howard@rocky9 ~]$ ls -l ~/.ssh/
total 8
-rw-------. 1 howard howard 399 Jun 15 13:46 id_ed25519
-rw-r--r--. 1 howard howard  95 Jun 15 13:46 id_ed25519.pub
```

Then add your newly created SSH key's public key to the bottom of the `vars.yaml` file. This would look like this:

```yaml
    ssh_key_path:
      # multiple keys are possible
      # - ~/.ssh/foo.bar.pub
      - ~/.ssh/id_rsa.pub
      - ~/.ssh/id_ed25519.pub
```

For more information on SSH keys, check out the Rocky Linux SSH Guide^7^.

#### Verify sudo permissions

For the kickstart tests, sudo passwordless mounting is required for the tests to pass.

Run the below command to edit the `sudoers` file:

```bash
sudo visudo
```

Then add this line (you can place it anywhere in the file), replacing `YOUR_USER_NAME_HERE` with your user:

```bash
## Sparky users
YOUR_USER_NAME_HERE ALL=(ALL) NOPASSWD: /usr/bin/mount,/usr/bin/umount
```

By default, `visudo` opens the `sudoers` file in the `vi` text editor. For a good introduction to `vi`, go through the Rocky Linux Book on the `vi` text editor^9^.

## Start services

Now, there are a few ways of doing this next step—`tmux`, `screen`, opening multiple shells, or just backgrounding the tasks. It does not matter which. Seeing the messages while debugging is helpful, so you may want to open new shells where you can watch them.

### Separate windows/tabs method

Run these two commands in separate windows/tabs/backgrounds. They should be run from the `sparky` directory, `~/Code/sparky`:

```bash
# Window/Tab 1
sparkyd
```

```bash
# Window/Tab 2
cro run
```

### tmux method

See the tmux cheat sheet^8^ for more information on navigating and manipulating `tmux`:

```text
tmux
sparkyd
"Ctrl+b" then ":new"
cd ~/Code/sparky
cro run
"Ctrl+b" then "s" to switch sessions
"Ctrl+b" then "d" to detach
# To list all tmux sessions:
tmux a
# To re-attach to a session:
tmux a -t <SESSION_NUMBER>
```

If you get an error along the lines of "Did not encounter any `.cro.yml` files... could it be `.cro.yml` file is missing?", then before running the above commands, ensure you are in the sparky folder `cd ~/Code/sparky` and try `cro run` again. You should get a `sparky run sparky web ui on host: 0.0.0.0, port: 4000` message if it is working.

### Start web browser

Now open a web browser to `http://your-IP:4000`

Login as `admin`:`admin`

### Launch test

Now go to `Projects`. You should see "sparky-rocky".

Click the link to view project details, then click "Build now".

Then you will have three options: `qemu`, `qemu_with_kickstart`, and `orb`. Select `qemu`.

Available options:

#### version

The image to test against. This drop down is populated from the `qemu_image` list in `~/.sparky/templates/vars.yaml`, so it shows the image names you configured (for example, `Rocky-9-GenericCloud`).

#### releasever

Choose the version that works with your image. The example used in this guide is Rocky Linux 9.8, so `9.8` would be selected here.

#### use_case_repo

What tests you want to run against the image you are deploying. For a test run, you can choose the Sparky_WP_LAMP^3^ test.

#### qemu_binary

By default, only `qemu-kvm` is selectable, so leave this option as is.

#### qemu_machine

This will be pre-populated with the `machine` that you set in `~/.sparky/templates/vars.yaml`. In this example, it is `pc-q35-rhel9.8.0`.

#### ssh_key_path

This will again be pre-populated with the key that you set in the SSH key creation step from `~/.sparky/templates/vars.yaml`.

#### bootstrap

If this option is checked, the image is rebuilt from scratch and the `Sparrow` client is installed fresh on the image.

#### qemu_shut

Checking this option means that when the test is done, Sparky closes down the QEMU session. Leaving the option unchecked leaves the QEMU session running, in case you want to access the session afterwards.

#### skip_test

When provisioning a VM, checking this option does not run the actual use-case test. This is useful when you just want a clean, running VM (or to prep an image) without the test phase.

#### dump_task_code

This prints the source code of each task as it runs, for debugging scenarios where you need to debug Sparky. It is part of the Sparrow6 framework.

### First run

For the first run, make sure bootstrap is checked and click "Submit".

You should see activity in the two window panes where you started `sparkyd` and `cro run`.

You should also see "build has started" which will then change to a job number link to the job report.

Click "Recent Builds". You should see the build running. Click the ID link for details on what state the job is in.

When the QEMU session first boots up, it will take a few minutes to run.

### Closing sessions

For those times when the QEMU session does not shut down, due to either one of the selections above or a failure that does not close it, run the below commands:

```bash
ssh -p 10022 admin@127.0.0.1
sudo init 0
```

If there is a notice about bad ssh keys, remove the problematic entries individually from `~/.ssh/known_hosts` using the below command or delete the whole `known_hosts` file if you do not need it:

```bash
ssh-keygen -R [127.0.0.1]:10022
```

The port number varies depending on the number of QEMU instances launched.

You should be able to observe the port number in the Test Reports.

### Clean session start

Some tests do not impact other tests, while other tests require a new QEMU VM image.

By default, the same QEMU image will be re-used.

Should you wish to freshly install the image, then enable the `bootstrap` option via the Job UI.

You should be able to always start with a fresh QEMU image when running any test.

If you run into failures re-using an image, please verify the issues on a fresh QEMU image, before filing a report.

## Results confirmation

Under `Recent Builds`, click the link to each result and under `Report` or `System Log`, this will tell you if a job succeeded or not.

### Results of the Rocky Linux LAMP check

There will be several sub-jobs launched. Results should be the same for Rocky 8.10 and 9.8:

- sparky-rocky - triggered by admin - should end with a result of "succeed"
- qemu-session - start qemu session - should be in a "running" state
- qemu-use-case - use case scenario - should end with a result of "succeed"

### Results of the ZFS test

There will be several sub-jobs launched. Results are for Rocky 9.8, as 8.10 needs tweaks not included in the ZFS test yet.

- sparky-rocky - triggered by admin - should end with a result of "succeed"
- qemu-session - start qemu session - should be in a "running" state
- qemu-use-case - use case scenario - should end with a result of "succeed"
- qemu-reboot - reboot qemu box - should end with a result of "succeed"
- qemu-use-case - use case scenario - should end with a result of "succeed"

Click on the ID of each job to get more details. You should see successful banners for `zpool status`, `zpool iostat`, and `zpool list`. Verify all items returned "True" under the "[task check]" section.

### Results of the Slurm test

There will be several sub-jobs launched. Results are for Rocky 9.8 as 8.10 has issues installing Slurm at this time.

- sparky-rocky - triggered by admin - should end with a result of "succeed"
- qemu-session - start qemu session - should be in a "running" state
- qemu-use-case - use case scenario - should end with a result of "succeed"

Click on the ID for the job to get more details. You should see a successful partition ("normal*      up 7-00:00:00      1   idle master"), followed by a message of "Test complete!"

## Writing new tests

### Creating a repository

For this step, you will be running multiple `git` commands. If you are unsure of how to use `git`, please check the [Rocky Linux Gemstone for git](../../gemstones/git/01-gh_cli_1st_pr.md) on how to add files and commit changes.

First, create a new directory to work from. This example will use `sparky-newtest` and this will create the template you will need:

```bash
cd ~/Code
mkdir -p sparky-newtest/tasks/check-newtest
cd sparky-newtest
echo "This is your README content; please explain something about this test." > README.md
echo -e '#!raku\ntask-run "tasks/check-newtest";' > main.raku
echo -e '#!/bin/bash -\necho "new test code here"' > tasks/check-newtest/task.bash
```

`main.raku` is the file that tells the Sparky job the details about what tasks to run. This is a very simple example; please refer to the documentation for more details.

`task.bash` is the task to run. This would be the shell script you want to run inside the QEMU VM.

To then commit the changes to your repository, here are example commands that you can run:

```bash
git init
git add .
git commit -m "Add sparky-newtest test scaffold"
git branch -M main
git remote add origin <your-repo-url>
git push -u origin main
```

### Modify vars.yaml to see your test

Once you have committed your code to a remote repository, edit `vars.yaml`:

```bash
nano ~/.sparky/templates/vars.yaml
```

Under `vars` -> `qemu_test` -> `use_case_repo`, add a new entry following YAML syntax with the Git URL. An example configuration would look like this:

```yaml
    use_case_repo:
      - https://github.com/metalllinux/Sparky_Test
      - https://git.resf.org/testing/Sparky_Bind
```

Refresh the web interface. It should appear at the bottom of the `use_case_repo` list.

Once you have something that works well, submit a Pull Request for us to add the repository.

## Upgrading

To upgrade, rerun the `zef` command from anywhere on the host:

```bash
zef upgrade --/test Sparrowdo
```

If your `Sparrowdo` is at the latest version, you will observe the below output:

```text
===> Searching for: Sparrowdo
All requested distributions are already at their latest versions
```

## Conclusion

With Sparky installed, configured, and running, you can launch the Rocky test scripts against Rocky Linux images and review the results in the web interface.

From there, you can write your own tests and submit them to the Rocky Linux Testing Team, so the wider community benefits from the coverage.

## References

1. "nano man pages" by rockyman.org [https://rockyman.org/9.8/nano/man1/nano.1.html](https://rockyman.org/9.8/nano/man1/nano.1.html)
2. "Raku" by The Raku Project [https://raku.org/](https://raku.org/)
3. "Rocky Linux LAMP Check" by Alexey Melezhik [https://github.com/melezhik/rocky-linux-lamp-check](https://github.com/melezhik/rocky-linux-lamp-check)
4. "Sparky Project" by Alexey Melezhik [https://github.com/melezhik/sparky](https://github.com/melezhik/sparky)
5. "Sparky Rocky" by Alexey Melezhik and Chris "Stack" Stackpole [https://git.resf.org/testing/Sparky_Rocky](https://git.resf.org/testing/Sparky_Rocky)
6. "Sparrow" by Alexey Melezhik and José Joaquín Atria [https://github.com/melezhik/Sparrow6](https://github.com/melezhik/Sparrow6)
7. "SSH public and private key" by Steven Spencer, Ezequiel Bruni, and Ganna Zhyrnova [https://docs.rockylinux.org/guides/security/ssh_public_private_keys/?h=ssh+key](https://docs.rockylinux.org/guides/security/ssh_public_private_keys/?h=ssh+key)
8. "Tmux Cheat Sheet & Quick Reference" by l9c and contributors [https://tmuxcheatsheet.com/](https://tmuxcheatsheet.com/)
9. "VI Text Editor" by Antoine Le Morvan, Ezequiel Bruni, Ganna Zhyrnova, Patrick Starrenburg, Serge Croisé, and Tianci Li [https://docs.rockylinux.org/10/books/admin_guide/05-vi/](https://docs.rockylinux.org/10/books/admin_guide/05-vi/)
