---

Title: Mellanox OFED Drivers
Author: Jordan Hayes

---

# Install Mellanox OFED Drivers

All tests and solutions here are describing `Mellanox OFED driver 4.9-3.1.5.0-rhel8.3-x86_64 LTS`, however this method could potentially be applied to any version of Mellaonx OFED (with varying results).

## Prepare

Python 2 does seem necessary since some scripts in the Mellanox OFED package are still Python 2:

```bash
# Workaround: To be removed when mlnx_tune has python3 support:
# mlnx_tune is a python2 script. Avoid generating dependencies
# from it in some distributions to avoid dragging in a python2
# dependency
```

So, we need both Python 2 and 3, so let's install `python2` as `python`:

```bash
yum install python2 -y
alternatives --config python
```

## Install

When installing an error is produced, however the logs are not very forthcoming (what a surprise):

```bash
./mlnxofedinstall -vvv --add-kernel-support --distro RHEL8.3                                                                                                                                                                     
Using provided distro: RHEL8.3                                                                                                                                                                                                                                                                                         
glibc-devel 32bit is required to install 32-bit libraries.                                                                                                                                                                                                                                                 
Note: This program will create MLNX_OFED_LINUX TGZ for rhel8.3 under /tmp/MLNX_OFED_LINUX-4.9-3.1.5.0-4.18.0-240.22.1.el8.x86_64 directory.                                                                                                                                           
See log file /tmp/MLNX_OFED_LINUX-4.9-3.1.5.0-4.18.0-240.22.1.el8.x86_64/mlnx_iso.4090689_logs/mlnx_ofed_iso.4090689.log                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                                       
Checking if all needed packages are installed...                                                                                                                                                                                                                                                                    
Building MLNX_OFED_LINUX RPMS . Please wait...                                                                                                                                                                                                                                                                         
                                                                                                                                                                                                                                                                                                                       
ERROR: Failed executing "MLNX_OFED_SRC-4.9-3.1.5.0/install.pl --tmpdir /tmp/MLNX_OFED_LINUX-4.9-3.1.5.0-4.18.0-240.22.1.el8.x86_64/mlnx_iso.4090689_logs --                                                                                                                                                           
kernel-only --kernel 4.18.0-240.22.1.el8.x86_64 --kernel-sources /lib/modules/4.18.0-240.22.1.el8.x86_64/build --builddir /tmp/MLNX_OFED_LINUX-4.9-3.1.5.0-                                                                                                                                                            
4.18.0-240.22.1.el8.x86_64/mlnx_iso.4090689 --disable-kmp --build-only --distro rhel8.3"                                                                                                                                                                                                                               
ERROR: See /tmp/MLNX_OFED_LINUX-4.9-3.1.5.0-4.18.0-240.22.1.el8.x86_64/mlnx_iso.4090689_logs/mlnx_ofed_iso.4090689.log                                                                                                                                                                                             
Failed to build MLNX_OFED_LINUX for 4.18.0-240.22.1.el8.x86_64
```

That command failed, but didnt say much about way, so lets reproduce the inner error and see if we can unearth something:

```
cd /tmp
MLNX_OFED_SRC-4.9-3.1.5.0/install.pl --tmpdir /tmp/MLNX_OFED_LINUX-4.9-3.1.5.0-4.18.0-240.22.1.el8.x86_64/mlnx_iso.4090689_logs --kernel-only --kernel 4.18.0-240.22.1.el8.x86_64 --kernel-sources /lib/modules/4.18.0-240.22.1.el8.x86_64/build --builddir /tmp/MLNX_OFED_LINUX-4.9-3.1.5.0-4.18.0-240.22.1.el8.x86_64/mlnx_iso.4090689 --disable-kmp --build-only --distro rhel8.3
Logs dir: /tmp/MLNX_OFED_LINUX-4.9-3.1.5.0-4.18.0-240.22.1.el8.x86_64/mlnx_iso.4090689_logs/OFED.938456.logs
General log file: /tmp/MLNX_OFED_LINUX-4.9-3.1.5.0-4.18.0-240.22.1.el8.x86_64/mlnx_iso.4090689_logs/OFED.938456.logs/general.log

Below is the list of OFED packages that you have chosen
(some may have been added by the installer due to package dependencies):

ofed-scripts
mlnx-ofa_kernel
mlnx-ofa_kernel-modules
mlnx-ofa_kernel-devel
knem
knem-modules
kernel-mft
iser
srp
isert
mlnx-nvme
rshim

This program will install the OFED package on your machine.
Note that all other Mellanox, OEM, OFED, RDMA or Distribution IB packages will be removed.
Those packages are removed due to conflicts with OFED, do not reinstall them.

Build ofed-scripts 4.9 RPM
Running  rpmbuild --rebuild  --define '_topdir /tmp/MLNX_OFED_LINUX-4.9-3.1.5.0-4.18.0-240.22.1.el8.x86_64/mlnx_iso.4090689/OFED_topdir' --define '_sourcedir %{_topdir}/SOURCES' --define '_specdir %{_topdir}/SPECS' --define '_srcrpmdir %{_topdir}/SRPMS' --define '_rpmdir %{_topdir}/RPMS'  --define 'dist %{nil}' --target x86_64 --define '_prefix /usr' --define '_exec_prefix /usr' --define '_sysconfdir /etc' --define '_usr /usr' /tmp/MLNX_OFED_SRC-4.9-3.1.5.0/SRPMS/ofed-scripts-4.9-OFED.4.9.3.1.5.src.rpm
Build mlnx-ofa_kernel 4.9 RPM

-W- --with-mlx5-ipsec is enabled
Running  rpmbuild --rebuild  --define '_topdir /tmp/MLNX_OFED_LINUX-4.9-3.1.5.0-4.18.0-240.22.1.el8.x86_64/mlnx_iso.4090689/OFED_topdir' --define '_sourcedir %{_topdir}/SOURCES' --define '_specdir %{_topdir}/SPECS' --define '_srcrpmdir %{_topdir}/SRPMS' --define '_rpmdir %{_topdir}/RPMS'  --nodeps --define '_dist .rhel8u3' --define 'configure_options   --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod --with-mlxfw-mod --with-mlx4-mod --with-mlx4_en-mod --with-mlx5-mod --with-mlx5-ipsec --with-ipoib-mod --with-innova-flex --with-innova-ipsec --with-mdev-mod --with-srp-mod --with-iser-mod --with-isert-mod' --define 'KVERSION 4.18.0-240.22.1.el8.x86_64' --define 'K_SRC /lib/modules/4.18.0-240.22.1.el8.x86_64/build' --define '_prefix /usr' /tmp/MLNX_OFED_SRC-4.9-3.1.5.0/SRPMS/mlnx-ofa_kernel-4.9-OFED.4.9.3.1.5.1.src.rpm
Failed to build mlnx-ofa_kernel 4.9 RPM
Collecting debug info...
See /tmp/MLNX_OFED_LINUX-4.9-3.1.5.0-4.18.0-240.22.1.el8.x86_64/mlnx_iso.4090689_logs/OFED.938456.logs/mlnx-ofa_kernel-4.9.rpmbuild.log
```

Yet again, the top level error is not informitive, however, when you look at the command that it fails on you can get a little hidden gem:

```bash
rpmbuild --rebuild  --define '_topdir /tmp/MLNX_OFED_LINUX-4.9-3.1.5.0-4.18.0-240.22.1.el8.x86_64/mlnx_iso.4090689/OFED_topdir' --define '_sourcedir %{_topdir}/SOURCES' --define '_specdir %{_topdir}/SPECS' --define '_srcrpmdir %{_topdir}/SRPMS' --define '_rpmdir %{_topdir}/RPMS'  --nodeps --define '_dist .rhel8u3' --define 'configure_options   --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod --with-mlxfw-mod --with-mlx4-mod --with-mlx4_en-mod --with-mlx5-mod --with-mlx5-ipsec --with-ipoib-mod --with-innova-flex --with-innova-ipsec --with-mdev-mod --with-srp-mod --with-iser-mod --with-isert-mod' --define 'KVERSION 4.18.0-240.22.1.el8.x86_64' --define 'K_SRC /lib/modules/4.18.0-240.22.1.el8.x86_64/build' --define '_prefix /usr' /tmp/MLNX_OFED_SRC-4.9-3.1.5.0/SRPMS/mlnx-ofa_kernel-4.9-OFED.4.9.3.1.5.1.src.rpm

...

Bytecompiling .py files below /tmp/MLNX_OFED_LINUX-4.9-3.1.5.0-4.18.0-240.22.1.el8.x86_64/mlnx_iso.4090689/OFED_topdir/BUILDROOT/mlnx-ofa_kernel-4.9-OFED.4.9.3.1.5.1.rhel8u3.x86_64/usr/lib/python2.7 using /usr/bin/python2.7
+ /usr/lib/rpm/brp-python-hardlink
+ PYTHON3=/usr/libexec/platform-python
+ /usr/lib/rpm/redhat/brp-mangle-shebangs
*** ERROR: ambiguous python shebang in /usr/bin/mlnx_qos: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/bin/tc_wrap.py: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/bin/mlnx_perf: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/bin/mlnx_qcn: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/bin/mlnx_dump_parser: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/bin/mlx_fs_dump: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
mangling shebang in /usr/sbin/mlnx_tune from /usr/bin/env python2 to #!/usr/bin/python2
*** ERROR: ambiguous python shebang in /usr/sbin/ib2ib_setup: #!/usr/bin/env python. Change it to python3 (or python2) explicitly.
*** WARNING: ./usr/src/ofa_kernel-4.9/net/sunrpc/xprtrdma/_makefile_ is executable but has no shebang, removing executable bit
*** WARNING: ./usr/src/ofa_kernel-4.9/drivers/infiniband/ulp/isert/_makefile_ is executable but has no shebang, removing executable bit
*** WARNING: ./usr/src/ofa_kernel-4.9/drivers/infiniband/ulp/iser/_makefile_ is executable but has no shebang, removing executable bit
*** WARNING: ./usr/src/ofa_kernel-4.9/drivers/infiniband/ulp/srp/_makefile_ is executable but has no shebang, removing executable bit
*** WARNING: ./usr/src/ofa_kernel-4.9/drivers/nvme/_makefile_ is executable but has no shebang, removing executable bit
*** WARNING: ./usr/src/ofa_kernel-4.9/backport_includes/2.6.18-EL5.2/include/src/idr.c is executable but has no shebang, removing executable bit
*** WARNING: ./usr/src/ofa_kernel-4.9/backport_includes/2.6.16_sles10_sp3/include/src/idr.c is executable but has no shebang, removing executable bit
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel-4.9/ofed_scripts/utils/mlnx_dump_parser: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel-4.9/ofed_scripts/utils/mlnx_mcg: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** WARNING: ./usr/src/ofa_kernel-4.9/ofed_scripts/utils/setup.py is executable but has no shebang, removing executable bit
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel-4.9/ofed_scripts/utils/mlnx_qos: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel-4.9/ofed_scripts/utils/mlnx_perf: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel-4.9/ofed_scripts/utils/mlnx_qcn: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel-4.9/ofed_scripts/utils/tc_wrap.py: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel-4.9/ofed_scripts/utils/mlx_fs_dump: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel-4.9/ofed_scripts/ib2ib/ib2ib_setup: #!/usr/bin/env python. Change it to python3 (or python2) explicitly.
*** WARNING: ./usr/src/ofa_kernel-4.9/ofed_scripts/mlnx_en/scripts/mlnx_en_uninstall.sh is executable but has no shebang, removing executable bit
mangling shebang in /usr/src/ofa_kernel-4.9/ofed_scripts/mlnx_tune from /usr/bin/env python2 to #!/usr/bin/python2
mangling shebang in /usr/src/ofa_kernel/default/ofed_scripts/mlnx_tune from /usr/bin/env python2 to #!/usr/bin/python2
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel/default/ofed_scripts/ib2ib/ib2ib_setup: #!/usr/bin/env python. Change it to python3 (or python2) explicitly.
*** WARNING: ./usr/src/ofa_kernel/default/ofed_scripts/mlnx_en/scripts/mlnx_en_uninstall.sh is executable but has no shebang, removing executable bit
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel/default/ofed_scripts/utils/build/scripts-2.7/mlnx_qos: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel/default/ofed_scripts/utils/build/scripts-2.7/tc_wrap.py: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel/default/ofed_scripts/utils/build/scripts-2.7/mlnx_perf: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel/default/ofed_scripts/utils/build/scripts-2.7/mlnx_qcn: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel/default/ofed_scripts/utils/build/scripts-2.7/mlnx_dump_parser: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel/default/ofed_scripts/utils/build/scripts-2.7/mlx_fs_dump: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel/default/ofed_scripts/utils/mlnx_dump_parser: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel/default/ofed_scripts/utils/mlnx_mcg: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** WARNING: ./usr/src/ofa_kernel/default/ofed_scripts/utils/setup.py is executable but has no shebang, removing executable bit
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel/default/ofed_scripts/utils/mlnx_qos: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel/default/ofed_scripts/utils/mlnx_perf: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel/default/ofed_scripts/utils/mlnx_qcn: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel/default/ofed_scripts/utils/tc_wrap.py: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
*** ERROR: ambiguous python shebang in /usr/src/ofa_kernel/default/ofed_scripts/utils/mlx_fs_dump: #!/usr/bin/python. Change it to python3 (or python2) explicitly.
error: Bad exit status from /var/tmp/rpm-tmp.pCtjOS (%install)


RPM build errors:
    user builder does not exist - using root
    group dip does not exist - using root
    user builder does not exist - using root
    group dip does not exist - using root
    Bad exit status from /var/tmp/rpm-tmp.pCtjOS (%install)
```

The `ambigous python shebang` error is being produced by `/usr/lib/rpm/redhat/brp-mangle-shebangs`.
This was an upstream change in Fedora -> RHEL 8 a while ago in [Make_ambiguous_python_shebangs_error](https://fedoraproject.org/wiki/Changes/Make_ambiguous_python_shebangs_error#Detailed_Description).
At first I thought it could be just commented out so that the script would not give this error when an ambigous python was detected.
However, this only led to RPMs not being able to install due to a `/usr/bin/python` dependency.

Looking into the `mlnx-ofa_kernel.spec` file there are some OS detection lines to force Python 3 in `RHEL 8` compatible systems:

```spec
# Force python3 on RHEL8, fedora3x, SLES15 and similar:
%global RHEL8 %(if test `grep -E '^(ID="(rhel|ol|centos)"|VERSION="8)' /etc/os-release 2>/dev/null | wc -l` -eq 2; then echo -n '1'; else echo -n '0'; fi)
%global FEDORA3X %{!?fedora:0}%{?fedora:%(if [ %{fedora} -ge 30 ]; then echo 1; else echo 0; fi)}
%global SLES15 0%{?suse_version} >= 1500
%global PYTHON3 %{RHEL8} || %{FEDORA3X} || %{SLES15}
```

## Solution

To activate this enforcement, a small (very dirty) hack is used to temporarily change the `os-release` to `rhel` during the install of the OFED drivers:

```bash
wget http://www.mellanox.com/page/mlnx_ofed_eula?mtag=linux_sw_drivers&mrequest=downloads&mtype=ofed&mver=MLNX_OFED-4.9-3.1.5.0&mname=MLNX_OFED_LINUX-4.9-3.1.5.0-rhel8.3-x86_64.tgz
tar -xf MLNX_OFED_LINUX-4.9-3.1.5.0-rhel8.3-x86_64.tgz
cd MLNX_OFED_LINUX-4.9-3.1.5.0-rhel8.3-x86_64
sed -i 's/^ID="rocky"/ID="rhel"/' /etc/os-release
./mlnxofedinstall -vvv --add-kernel-support --distro RHEL8.3
sed -i 's/^ID="rhel"/ID="rocky"/' /etc/os-release
```

This seems to install without any issues.

