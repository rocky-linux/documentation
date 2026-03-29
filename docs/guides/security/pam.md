---
title: PAM authentication modules
author: Antoine Le Morvan
contributors: Steven Spencer, Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6
tags:
  - security
  - pam
---

# PAM Authentication Modules

## Description of Document Content

In this chapter, you will learn the following knowledge about PAM:

1. Basic theoretical content
1. Configuration file description
1. Using PAM to enhance the security of the operating system

Prerequisites and Assumptions:

* A non-critical Rocky Linux PC, server, or VM
* Root access
* Some existing Linux knowledge (would help a lot)
* A desire to learn about user and app authentication on Linux
* The ability to accept the consequences of your own actions

## Introduction

PAM (**Pluggable Authentication Modules**) is the system under GNU/Linux that allows many applications or services to authenticate users in a centralized fashion. PAM was initially proposed by **Vipin Samar** and **Charlie Lai** of Sun Microsystems (later acquired by Oracle) in 1995 and implemented on their Solaris system. Later, various UNIX variants and GNU/Linux distributions also added support for it. The original intention of PAM's design was to integrate different underlying authentication mechanisms into a high-level API, saving developers the trouble of designing and implementing various complex authentication mechanisms themselves. In 1997, the Open Group published the X/Open Single Sign-on (XSSO) preliminary specification, which standardized the PAM API and added extensions for single (or rather integrated) sign-on.

PAM is open source, you can find more information [here](https://github.com/linux-pam/linux-pam).

**Q: Why is it necessary to use PAM?**

* How to ensure that the users of the applications, services, or tools used in the system are always themselves?
* How to specify time periods for system users to restrict access to services?
* How to limit the usage of system resources by various applications or services?
* ...

Without PAM, authentication functions can only be written in various applications. Once a certain authentication method needs to be modified, developers may have to rewrite the program, recompile it, and install it again. With PAM, the identity authentication work of the application is entrusted to PAM, and the program subject can no longer focus on the issue of identity authentication itself.

PAM is mainly composed of a group of shared files (files ending with the .so extension) and some configuration files. Its main characteristics are as follows:

* Based on modular design and with insertable functionality
* The authentication method is independent of the application
* Provide developers with a unified API
* High flexibility, allowing applications to freely choose the required authentication method through PAM
* Enhance operating system security

## Terms in PAM

In the early days of PAM, **Vipin Samar** and **Charlie Lai** did not formally define these terms, but they did indeed use those terms that were not formally defined, which led to misleading or incomprehensible situations when using some terms. In 1999, **Andrew G.Morgan** (author of Linux-PAM) established consistent and clear terminology for the first time in his white paper, although it was not yet perfect. The explanations of the following terms are sourced from FreeBSD's documentation:

* **account** - The set of credentials the applicant is requesting from the arbitrator.
* **applicant** - The user or entity requesting authentication.
* **arbitrator** - The user or entity who has the privileges necessary to verify the applicant’s credentials and the authority to grant or deny the request.
* **chain** - A sequence of modules that will be invoked in response to a PAM request. The chain includes information about the order in which to invoke the modules, what arguments to pass to them, and how to interpret the results.
* **client** - The application responsible for initiating an authentication request on behalf of the applicant and for obtaining the necessary authentication information from him.
* **facility** - One of the four basic groups of functionality provided by PAM: **_authentication_**, **_account management_**, **_session management_** and **_authentication token update_**.
* **module** - A collection of one or more related functions implementing a particular authentication facility, gathered into a single (normally dynamically loadable) binary file and identified by a single name.
* **policy** - The complete set of configuration statements describing how to handle PAM requests for a particular service. **_A policy normally consists of four chains, one for each facility, though some services do not use all four facilities_**.
* **server** - The application acting on behalf of the arbitrator to converse with the client, retrieve authentication information, verify the applicant’s credentials and grant or deny requests.
* **service** - A class of servers providing similar or related functionality and requiring similar authentication. PAM policies are defined on a per-service basis, so all servers that claim the same service name will be subject to the same policy.
* **session** - The context within which service is rendered to the applicant by the server. One of PAM’s four facilities, session management, is concerned exclusively with setting up and tearing down this context.
* **token** - A chunk of information associated with the account, such as a password or passphrase, which the applicant must provide to prove his identity.
* **transaction** - A sequence of requests from the same applicant to the same instance of the same server, beginning with authentication and session set-up and ending with session tear-down.

### Illustrate the terms with examples

Client and Server Are One:

```bash
bash > whoami
alice

bash > ls -l `which su`

bash > su  - 
Password: 1Q.3werzasd

bash > whoami
root
```

* The applicant is alice
* The account is root
* The su process is both client and server
* The authentication token is 1Q.3werzasd
* The arbitrator is root

Client and Server Are Separate:

```bash
bash > whoami
eve

bash > ssh bob@login.example.com
bob@login.example.com's password:
god
Last login: Thu Oct 11 09:52:57 2024 from 192.168.0.1

```

* The applicant is eve
* The client is Eve’s ssh process
* The server is the sshd process on login.example.com
* The account is bob
* The authentication token is god
* Although this is not shown in this example, the arbitrator is root

### Example policy

```
sshd	auth		required	pam_nologin.so	no_warn
sshd	auth		required	pam_unix.so	no_warn try_first_pass
sshd	account		required	pam_login_access.so
sshd	account		required	pam_unix.so
sshd	session		required	pam_lastlog.so	no_fail
sshd	password	required	pam_permit.so
```

* This policy is applicable to sshd service
* auth, account, session, and password are facilities
* pam_nologin.so, pam_unix.so, pam_login_access.so, pam_lastlog.so and pam_permit.so are modules. From this example, it can be seen that pam_unix.so has at least implemented two functionality groups (authentication and account management)

## PAM Essentials

### Facilities and Primitives

**Primitive** concepts in computer science: A process consisting of several instructions, used to accomplish a specific function. These instructions are combined to form a program, which cannot be divided or interrupted during execution, ensuring the continuity and integrity of the operation. Generally speaking, primitives are typically provided by hardware or operating systems to implement critical system functions.

The PAM API provides six different authentication primitives, which are divided into four types of facilities:

1. **auth** - Authentication. This facility concerns itself with authenticating the applicant and establishing the account credentials.
2. **account** - Account management. This facility handles non-authentication-related issues of account availability, such as access restrictions based on the time of day or the server’s work load. 
3. **session** - Session management. This facility handles tasks associated with session set-up and tear-down, such as login accounting. 
4. **password** - Password management. This facility is used to change the authentication token associated with an account, either because it has expired or because the user wishes to change it.

!!! tip "Different definitions"

    Some distributions define these 4 facilities as "module interfaces".

### Modules

A PAM module is a self-contained piece of program code that implements the primitives in one or more facilities for one particular mechanism. Simply put, the modules in PAM are a collection of one or more related functions that implement specific authentication functions.

Requesting the PAM module will return one of the following three states:

1. success - Meet security policy
2. failure - Not meeting security policy
3. ignore - Request not involved in security policy

### Chains and Policies

When a server initiates a PAM transaction, the PAM library tries to load a policy for the service specified in the [pam_start(3)](https://www.man7.org/linux/man-pages/man3/pam_start.3.html) call. The policy specifies how authentication requests should be processed, and is defined in a configuration file. This is the other central concept in PAM: the possibility for the admin to tune the system security policy (in the wider sense of the word) simply by editing a text file.

A policy consists of four chains, one for each of the four PAM facilities. Each chain is a sequence of configuration statements, each specifying a module to invoke, some (optional) parameters to pass to the module, and a control flag that describes how to interpret the return code from the module.

#### Control flags

These control flags include:

* `binding` - If the module succeeds and no earlier module in the chain has failed, the chain is immediately terminated and the request is granted. If the module fails, the rest of the chain is executed, but the request is ultimately denied
* `required` - The module result must be successful for authentication to continue. If the test fails at this point, the user is not notified until the results of all module tests that reference that interface are complete
* `requisite` - The module result must be successful for authentication to continue. However, if a test fails at this point, the user is notified immediately with a message reflecting the first failed "required" or "requisite" module test
* `optional` - The module result is ignored. A module flagged as "optional" only becomes necessary for successful authentication when no other modules reference the interface
* `sufficient` - The module result is ignored if it fails. However, if the result of a module flagged "sufficient" is successful and no previous modules flagged "required" have failed, then no other results are required and the user is authenticated to the service
* `include` - Unlike the other controls, this does not relate to how the module result is handled. This flag pulls in all lines in the configuration file which match the given parameter and appends them as an argument to the module

The following figure shows how to record the success or failure of each control flag:

![](./images/pam-control-flags.jpg)

For other control flags, please refer to `man 5 pam.conf`.

When a server invokes one of the six PAM primitives, PAM retrieves the chain for the facility the primitive belongs to, and invokes each of the modules listed in the chain, in the order they are listed, until it reaches the end, or determines that no further processing is necessary (either because a "binding" or "sufficient" module succeeded, or because a "requisite" module failed.) The request is granted if and only if at least one module was invoked, and all non-optional modules succeeded.

!!! tip "tip"
    
    Note that it is possible, though not very common, to have the same module listed several times in the same chain. For instance, a module that looks up user names and passwords in a directory server could be invoked multiple times with different parameters specifying different directory servers to contact. PAM considers different positions of the same module appearing in the same chain as distinct and unrelated modules.

## Configuration file description

In the traditional old version of PAM, the configuration file was /etc/pam.conf. Currently, most distributions have abandoned this configuration file. This file contains all the policies related to identity authentication for the operating system. Each line represents a configuration statement in a certain chain of a certain service, and its syntax is as follows:

```bash
login   auth    required        pam_nologin.so   no_warn
```

The fields are, in order: service name, facility name, control flag, module name, and module arguments. Any additional fields are interpreted as additional module arguments.

> A policy consists of four chains, one for each of the four PAM facilities. Each chain is a sequence of configuration statements, each specifying a module to invoke, some (optional) parameters to pass to the module, and a control flag that describes how to interpret the return code from the module.
> A policy normally consists of four chains, one for each facility, though some services do not use all four facilities.

OpenPAM and Linux-PAM support another configuration mechanism, which is to centralize policy files into the **/etc/pam.d/** directory, where the service name is used as the file name to represent the policy file for that service.

```bash
bash > ls -l /etc/pam.d/
total 88
-rw-r--r--. 1 root root 232 Nov 27 03:04 config-util
-rw-r--r--. 1 root root 322 Nov 30  2023 crond
-rw-r--r--. 1 root root 701 Nov 27 03:04 fingerprint-auth
-rw-r--r--. 1 root root 715 Feb  9  2024 login
-rw-r--r--. 1 root root 154 Nov 27 03:04 other
-rw-r--r--. 1 root root 168 Apr 20  2022 passwd
-rw-r--r--. 1 root root 760 Nov 27 03:04 password-auth
-rw-r--r--  1 root root 155 May 28  2024 polkit-1
-rw-r--r--. 1 root root 398 Nov 27 03:04 postlogin
-rw-r--r--. 1 root root 640 Feb  9  2024 remote
-rw-r--r--. 1 root root 143 Feb  9  2024 runuser
-rw-r--r--. 1 root root 138 Feb  9  2024 runuser-l
-rw-r--r--  1 root root 153 Nov 27 03:04 smartcard-auth
-rw-r--r--. 1 root root 727 Aug 14 04:36 sshd
-rw-r--r--. 1 root root 214 Dec 18 01:38 sssd-shadowutils
-rw-r--r--. 1 root root 566 Feb  9  2024 su
-rw-r--r--. 1 root root 154 Feb 15  2024 sudo
-rw-r--r--. 1 root root 178 Feb 15  2024 sudo-i
-rw-r--r--. 1 root root 137 Feb  9  2024 su-l
-rw-r--r--. 1 root root 760 Nov 27 03:04 system-auth
-rw-r--r--  1 root root 368 Dec 18 01:56 systemd-user
-rw-r--r--. 1 root root  84 Jun 22  2023 vlock
```

```bash
bash > grep -v ^# /etc/pam.d/sshd
auth       substack     password-auth
auth       include      postlogin
account    required     pam_sepermit.so
account    required     pam_nologin.so
account    include      password-auth
password   include      password-auth
session    required     pam_selinux.so close
session    required     pam_loginuid.so
session    required     pam_selinux.so open env_params
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    optional     pam_motd.so
session    include      password-auth
session    include      postlogin
```

The content of each policy file can consist of up to four fields:

1. TYPE - One of auth, session, password, or account
2. CONTROL - Control flag
3. MOUDLE_PATH - Module paths and modules ending in .so. For 64-bit operating systems, all modules can be found in **/lib64/security/**
4. MOUDLE_ARGS - Module arguments used to control module behavior. optional

In the **/etc/security/** directory, there are global configuration files for PAM modules, which define the exact behavior of these modules. For each application using the PAM module, a set of PAM functions will be called, which will then process the information in the configuration file and return the results to the requesting application.

Due to PAM's policy being determined by file name rather than specified in the content of the policy file, the same policy file can be used for multiple services with different names. For example:

```bash
bash > cd /etc/pam.d/ && ln -s sudo ftp
```

### Explanation of the content of the policy file

```bash
bash > cat /etc/pam.d/system-auth
#%PAM-1.0
# This file is auto-generated.
# User changes will be destroyed the next time authselect is run.
auth        required      pam_env.so
auth        sufficient    pam_unix.so try_first_pass nullok
auth        required      pam_deny.so

account     required      pam_unix.so

password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=
password    sufficient    pam_unix.so try_first_pass use_authtok nullok sha512 shadow
password    required      pam_deny.so

session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
-session     optional      pam_systemd.so
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     required      pam_unix.so

bash > cat /etc/pam.d/login
#%PAM-1.0
auth       substack     system-auth
auth       include      postlogin
account    required     pam_nologin.so
account    include      system-auth
password   include      system-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
session    optional     pam_console.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    include      system-auth
session    include      postlogin
-session   optional     pam_ck_connector.so
```

Content description:

* `#%PAM-1.0` - Declaring the version of this configuration file for PAM1.0 is a habit that you can use to check versions in the future. Similar to the "#!/bin/bash" in bash scripts.
* `# This file is auto-generated.` - Lines starting with `#` represent comment lines.
* `-session` - The prefix "-" indicates that even if the module does not exist, it will not affect the authentication result, let alone record this event in the log. This feature is very useful for modules that are optional.
* `include` - Special control flag.
* `substack` - Special control flag. There is a slight difference from the "include" control flag. For example, a "requisite" failure in the sub-stack will only cause the sub-stack to terminate and return the failure result, without immediately terminating the parent stack. In PAM, "stack" refers to the execution steps and rules, and a sub-stack refers to another stack nested within a stack (the parent stack).
* From the content, it can be seen that the writing style of control flags can not only use keywords (they are called "keyword" mode), but also have a **[value1=action1  value2=action2 ... ]** style, which calls the return code of the function in the line module.

    * "value" can have: success, open_err, symbol_err, service_err, system_err, buf_err, perm_denied, auth_err, cred_insufficient, authinfo_unavail, user_unknown, maxtries, new_authtok_reqd, acct_expired, session_err, cred_unavail, cred_expired, cred_err, no_module_data, conv_err, authtok_err, authtok_recover_err, authtok_lock_busy, authtok_disable_aging, try_again, ignore, abort, authtok_expired, module_unknown, bad_item, conv_again, incomplete, and default.
    * "action" can be one of them: ignore, bad, die, ok, done, N(N must be a positive integer greater than 0. If it is equal to 0, it is equivalent to OK), reset

* `pam_unix.so` - Module path and module name. The path here refers to **/lib64/security/** relative path.
* `use_authtok nullok sha512 shadow` - Optional module arguments passed to the module. To view all optional parameters for a specific module, enter `man 8 Module-Name`, for example `man 8 pam_unix`.

### system-auth

system-auth is a very important PAM policy file, mainly responsible for authenticating user login to the system. Not only that, other programs or services can call it through the include keyword, saving a lot of time that needs to be reconfigured. When you are unsure how to configure, you need to first search for the corresponding information or consult relevant technical personnel.

```bash
bash > cat /etc/pam.d/system-auth
#%PAM-1.0
# This file is auto-generated.
# User changes will be destroyed the next time authselect is run.
auth        required      pam_env.so
auth        sufficient    pam_unix.so try_first_pass nullok
auth        required      pam_deny.so

account     required      pam_unix.so

password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=
password    sufficient    pam_unix.so try_first_pass use_authtok nullok sha512 shadow
password    required      pam_deny.so

session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
-session     optional      pam_systemd.so
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     required      pam_unix.so
```

As you can see, this policy file uses a complete set of 4 chains, each chain corresponds to a facility, and each facility can be stacked (i.e. the same facility writes multiple lines, and each line calls the same or different modules). Emphasize again:

> PAM considers different positions of the same module appearing in the same chain as distinct and unrelated modules.

#### auth chain

When a user logs in, the user's identity will be identified and password verified through **auth**.

* **pam_env.so** - Define environment variables after user login. By default, if no configuration file is specified, environment variables are set based on the **/etc/security/pam_env.conf**  file.
* **pam_unix.so** - Use this module to prompt the user to enter their password and compare it with the password information recorded in **/etc/shadow**. If the password comparison result is correct, the user is allowed to log in. Using the "sufficient " control flag means that as long as the verification of this configuration item is passed, the user can fully authenticate without having to request other modules. The nullok module parameter indicates that null passwords are allowed.
* **pam_deny.so** - Directly reject all login requests that do not meet any of the above conditions through the **pam_deny.so** module. **pam_deny.so** is a special module that always returns a value of "no". Similar to the configuration criteria of most security mechanisms, requests that do not match the authentication rules will be directly rejected after all authentication rules have been completed.

#### account chain

* **pam_unix.so** - Indicates that the user needs to pass password verification.

#### password chain

* **pam_pwquality.so** - Check the complexity of passwords, with commonly used module parameters as follows:

    * debug	- Enable this parameter to write the behavior information of the module to syslog
    * authtok_type=XXX - The default action is for the module to use the following prompts when requesting passwords: "New UNIX password: " and "Retype UNIX password: ". The example word UNIX can be replaced with this option, by default it is empty.
    * try_first_pass - Indicates that the module should first use the password obtained from the previous module, and if the password verification fails, prompt the user to enter a new password.
    * local_users_only - Indicates to ignore users who are not present in the local **/etc/passwd** file.
    * retry=N - The number of password retries allowed after changing the password, default value is 1.
    * minlen=N - What is the minimum length for a new password? The default value is 8.
    * difok=N - What is the minimum number of characters that must differ between the new and old passwords? The default value is 1. The special value of 0 disables all checks of similarity of the new password with the old password except the new password being exactly the same as the old one.
    * dcredit=N - When N>0, it indicates the maximum number of allowed numeric characters in the new password. When N<0, this indicates the minimum number of numeric characters required for the new password. When N=0, it means that the number of numeric characters in the new password is not limited.
    * lcredit=N - When N>0, it indicates the maximum number of lowercase letters allowed in the new password. When N<0, this indicates the minimum number of lowercase letters that must be included in the new password. When N=0, this indicates that there is no limit on the number of lowercase letters in the new password.
    * ucredit=N - When N>0, it indicates the maximum number of uppercase letters allowed in the new password. When N<0, this indicates the minimum number of uppercase letters that must be included in the new password. When N=0, this indicates that there is no limit on the number of uppercase letters in the new password.
    * ocredit=N - When N>0, it indicates the maximum number of special characters allowed in the new password. When N<0, this indicates the minimum number of special characters that must be included in the new password. When N=0, this indicates that there is no limit on the number of special characters in the new password.
    * maxrepeat=N - Reject passwords containing N or more identical consecutive characters. The default value is 0, indicating that this check is disabled.
    * maxsequence=N - Reject passwords which contain monotonic character sequences longer than N.  The default is 0 which means that this check is disabled.  Examples of such sequence are '12345' or 'fedcb'. Note that most such passwords will not pass the simplicity check unless the sequence is only a minor part of the password.
    * maxclassrepeat=N - Reject passwords which contain more than N consecutive characters of the same class. The default is 0 which means that this check is disabled.
    * enforce_for_root - After adding this parameter, it indicates that the password complexity requirement applies to the root user.

#### session chain

## Actual configuration case

## Generalities

Authentication is the phase during which it is verified that you are the person you claim to be. The most common example is the password, but other forms of authentication exist.

![PAM generalities](images/pam-001.png)

Implementing a new authentication method should not require changes in source code for program or service configuration. This is why applications rely on PAM, which gives them the primitives* necessary to authenticate their users.

All the applications in a system can thus implement complex functionalities such as **SSO** (Single Sign On), **OTP** (One Time Password) or **Kerberos** in a completely transparent manner. A system administrator can choose exactly which authentication policy is to be used for a single application (e.g. to harden the SSH service) independently of the application.

Each application or service supporting PAM will have a corresponding configuration file in the `/etc/pam.d/` directory. For example, the process `login` assigns the name `/etc/pam.d/login` to its configuration file.

\* Primitives are literally the simplest elements of a program or language, allowing you to build more sophisticated and complex things on top of them.

!!! WARNING

    A misconfigured instance of PAM can compromise the security of your whole system. If PAM is vulnerable, then the whole system is vulnerable. Make any changes with care.

## Directives

A directive is used to set up an application for usage with PAM. Directives will follow this format:

```
mechanism [control] path-to-module [argument]
```

A **directive** (a complete line) is composed of a **mechanism** (`auth`, `account`, `password` or `session`), a **success check** (`include`, `optional`, `required`, ...), the **path to the module** and possibly **arguments** (like `revoke` for example).

Each PAM configuration file contains a set of directives. The module interface directives can be stacked or placed on top of each other. In fact, **the order in which the modules are listed is very important to the authentication process.**

For example, here's the config file `/etc/pam.d/sudo`:

```
#%PAM-1.0
auth       include      system-auth
account    include      system-auth
password   include      system-auth
session    include      system-auth
```

## Mechanisms

### `auth` - Authentication

This handles the authentication of the requester and establishes the rights of the account:

* Usually authenticates with a password by comparing it to a value stored in a database, or by relying on an authentication server,

* Establishes account settings: uid, gid, groups, and resource limits.

### `account` - Account management

Checks that the requested account is available:

* Relates to the availability of the account for reasons other than authentication (e.g. for time restrictions).

### `session` - Session management

Relates to session setup and termination:

* Performs tasks associated with session setup (e.g. logging),
* Performs tasks associated with session termination.

### `password` - Password management

Used to modify the authentication token associated with an account (expiration or change):

* Changes the authentication token and possibly verifies that it is robust enough or has not already been used.

## Control Indicators

The PAM mechanisms (`auth`, `account`, `session` and `password`) indicate `success` or `failure`. The control flags (`required`, `requisite`, `sufficient`, `optional`) tell PAM how to handle this result.

### `required`

Successful completion of all `required` modules is necessary.

* **If the module passes:** The rest of the chain is executed. The request is allowed unless other modules fail.

* **If the module fails:** The rest of the chain is executed. Finally the request is rejected.

The module must be successfully verified for the authentication to continue. If the verification of a module marked `required` fails, the user is not notified until all modules associated with that interface have been verified.

### `requisite`

Successful completion of all `requisite` modules is necessary.

* **If the module passes:** The rest of the chain is executed. The request is allowed unless other modules fail.

* **If the module fails:** The request is immediately rejected.

The module must be successfully verified for authentication to continue. However, if the verification of a `requisite`-marked module fails, the user is immediately notified by a message indicating the failure of the first `required` or `requisite` module.

### `sufficient`

Modules marked `sufficient` can be used to let a user in "early" under certain conditions:

* **If the module succeeds:** The authentication request is immediately allowed if none of the previous modules failed.

* **If the module fails:** The module is ignored. The rest of the chain is executed.

However, if a module check marked `sufficient` is successful, but modules marked `required` or `requisite` have failed their checks, the success of the `sufficient` module is ignored, and the request fails.

### `optional`

The module is executed but the result of the request is ignored. If all modules in the chain were marked `optional`, all requests would always be accepted.

### Conclusion

![Rocky Linux installation splash screen](images/pam-002.png)

## PAM modules

There are many modules for PAM. Here are the most common ones:

* pam_unix
* pam_ldap
* pam_wheel
* pam_cracklib
* pam_console
* pam_tally
* pam_securetty
* pam_nologin
* pam_limits
* pam_time
* pam_access

### `pam_unix`

The `pam_unix` module allows you to manage the global authentication policy.

In `/etc/pam.d/system-auth` you might add:

```
password sufficient pam_unix.so sha512 nullok
```

Arguments are possible for this module:

* `nullok`: in the `auth` mechanism allows an empty login password.
* `sha512`: in the password mechanism, defines the encryption algorithm.
* `debug`: sends information to `syslog`.
* `remember=n`: Use this to remember the last `n` passwords used (works in conjunction with the `/etc/security/opasswd` file, which is to be created by the administrator).

### `pam_cracklib`

The `pam_cracklib` module allows you to test passwords.

In `/etc/pam.d/password-auth` add:

```
password sufficient pam_cracklib.so retry=2
```

This module uses the `cracklib` library to check the strength of a new password. It can also check that the new password is not built from the old one. It *only* affects the password mechanism.

By default this module checks the following aspects and rejects if this is the case:

* Is the new password from the dictionary?
* Is the new password a palindrome of the old one (e.g.: azerty <> ytreza)?
* Has the user only changed the password case (e.g.: azerty <>AzErTy)?

Possible arguments for this module:

* `retry=n`: imposes `n` requests (1` by default) for the new password.
* `difok=n`: imposes at least `n` characters (`10` by default), different from the old password. If half of the characters of the new password are different from the old one, the new password is validated.
* `minlen=n`: imposes a password of `n+1` characters minimum. You cannot assign a minimum lower than 6 characters (the module is compiled this way).

Other possible arguments:

* `dcredit=-n`: imposes a password containing at least `n` digits,
* `ucredit=-n`: imposes a password containing at least `n` capital letters,
* `credit=-n`: imposes a password containing at least `n` lower case letters,
* `ocredit=-n`: imposes a password containing at least `n` special characters.

### `pam_tally`

The `pam_tally` module allows you to lock an account based on a number of unsuccessful login attempts.

The default config file for this module might look like: `/etc/pam.d/system-auth`:

```
auth required /lib/security/pam_tally.so onerr=fail no_magic_root
account required /lib/security/pam_tally.so deny=3 reset no_magic_root
```

The `auth` mechanism accepts or denies authentication and resets the counter.

The `account` mechanism increments the counter.

Some arguments of the pam_tally module include:

* `onerr=fail`: increments the counter.
* `deny=n`: once the number `n` of unsuccessful attempts is exceeded, the account is locked.
* `no_magic_root`: can be used to deny access to root-level services launched by daemons. 
    * e.g. don't use this for `su`.
* `reset`: resets the counter to 0 if the authentication is validated.
* `lock_time=nsec`: the account is locked for `n` seconds.

This module works together with the default file for unsuccessful attempts `/var/log/faillog` (which can be replaced by another file with the argument `file=xxxx`), and the associated command `faillog`.

Syntax of the faillog command:

```
faillog[-m n] |-u login][-r]
```

Options:

* `m`: to define, in the command display, the maximum number of unsuccessful attempts,
* `u`: to specify a user,
* `r`: to unlock a user.

### `pam_time`

The `pam_time` module allows you to limit the access times to services managed by PAM.

To activate it, edit `/etc/pam.d/system-auth` and add:

```
account required /lib/security/pam_time.so
```

The configuration is done in the `/etc/security/time.conf` file:

```
login ; * ; users ;MoTuWeThFr0800-2000
http ; * ; users ;Al0000-2400
```

The syntax of a directive is as follows:

```
services; ttys; users; times
```

In the following definitions, the logical list uses:

* `&`: is the "and" logical.
* `|`: is the "or" logical.
* `!`: means negation, or "all except".
* `*`: is the wildcard character.

The columns correspond to:

* `services`: a logical list of services managed by PAM that are also to be managed by this rule
* `ttys`: a logical list of related devices
* `users`: logical list of users managed by the rule
* `times`: a logical list of authorized time slots

How to manage time slots:

* Days: `Mo`, `Tu`, `We`, `Th`, `Fr,` `Sa`, `Su`, `Wk`, (Monday to Friday), `Wd` (Saturday and Sunday), and `Al` (Monday to Sunday)
* The hourly range: `HHMM-HHMM`
* A repetition cancels the effect: `WkMo` = all days of the week (M-F), minus Monday (repeat).

Examples:

* Bob, can login via a terminal every day between 07:00 and 09:00, except Wednesday:

```
login; tty*; bob; alth0700-0900
```

No login, terminal or remote, except root, every day of the week between 17:30 and 7:45 the next day:

```
login; tty* | pts/*; !root; !wk1730-0745
```

### `pam_nologin`

The `pam_nologin` module disables all accounts except root:

In `/etc/pam.d/login` you'd put:

```
auth required pam_nologin.so
```

Only root can connect if the file `/etc/nologin` exists and is readable.

### `pam_wheel`

The `pam_wheel` module allows you to limit the access to the `su` command to the members of the `wheel` group.

In `/etc/pam.d/su` you'd put:

```
auth required pam_wheel.so
```

The argument `group=my_group` limits the use of the `su` command to members of the group `my_group`

!!! NOTE

    If the group `my_group` is empty, then the `su` command is no longer available on the system, which forces the use of the sudo command.

### `pam_mount`

The `pam_mount` module allows you to mount a volume for a user session.

In `/etc/pam.d/system-auth` you'd put:

```
auth optional pam_mount.so
password optional pam_mount.so
session optional pam_mount.so
```

Mount points are configured in the `/etc/security/pam_mount.conf` file:

```
<volume fstype="nfs" server="srv" path="/home/%(USER)" mountpoint="~" />
<volume user="bob" fstype="smbfs" server="filesrv" path="public" mountpoint="/public" />
```

## Wrapping Up

By now, you should have a much better idea of what PAM can do, and how to make changes when needed. However, we must reiterate the importance of being very, *very* careful with any changes you make to PAM modules. You could lock yourself out of your system, or worse, let everyone else in.

We would strongly recommend testing all changes in an environment that can be easily reverted to a previous configuration. That said, have fun with it!
