---
title: Rocky Linux Git Contributor Agreement
---

Account Services helps the Rocky Enterprise Software Foundation keep track of
contributors as well as the projects that they work on. This agreement goes over
the RESF Git Service (Forgejo) and the Rocky Linux GitLab instance, as well as
their overall usage and what is expected for contributors.

We require that contributors of Rocky (RESF) accept the following agreement, as
it provides access to the RESF Git Service.

Please read carefully before accepting this agreement.

Preface
=======

The RESF Git Service (Forgejo) is a core part of the Rocky Enterprise Software
Foundation. It is used to host code/software that is under the RESF or provide
the teams within the Rocky ecosystem to manage their own projects, code, wiki,
and so on. It will also act as a mirror for some repositories from the Rocky
GitHub organizations and in some special cases, mirrors from the Rocky Linux
GitLab instance.

The Rocky Linux GitLab instance is a core part of the Rocky Linux build
ecosystem, and thus a mode of the development process for the distribution and
available software. Being a user of the Rocky Linux GitLab allows you (the user)
to create repositories, open issues, and collaborate on Special Interest Groups,
and fixing all types of issues within the ecosystem, such as assets or failed
patches.

This agreement does not cover, nor affect the ability to contribute to any of
the Rocky GitHub organizations.

General Guidelines
==================

As a contributor, there are guidelines in which you (the user) and others must
follow. Below are a list of general things to be aware of:

* Moderation is enforced - As is done in the Rocky Linux MatterMost chat, it is
  important to mind your language and word choice. Speak to others as you would
  want them to speak to you.

* A valid GPG key must be uploaded and used to sign your commits. Signed
  commits, as a general rule, are considered **required**. Expect that most git
  repositories will have unsigned commits disabled.

* Accounts that are not in use or have not logged in may be deactivated or
  disabled

* Do not treat any git service as a general purpose Rocky Linux bug tracker.
  All issues should be tracked at our current bug tracker at
  https://bugs.rockylinux.org. Issues pertaining to a project under RESF may
  have other guidelines.

Expectations
============

As a contributor, there are expectations for you (the user) and others who work
in and interact with the git service. Below are a list of expectations we have
of you:

* Do not create personal repositories - If the repository is not for the RESF,
  Rocky Linux, a SIG, a "people" page / area of work, or planned Rocky
  contributions, it should not be created.

* You will retain ownership of your contributions - Anything contributed by you
  (the user) will not be taken away from you or your name removed from said
  contributions, as outlined in the Rocky Open Source Contributor Agreement.

* Git is not a Rocky Linux bug tracker - All issues related to Rocky Linux 
  should be tracked at our current bug tracker. Depending on the SIG, issues
  with the software or otherwise can be tracked either with their repositories
  or the bug tracker. This does not stop you (the user) from opening issues or
  PR's to improve or fix other issues without opening a bug report in most
  circumstances.

* Users must have GPG keys assigned to their account and their commits signed
  for specific repositories as configured.

Repository/Project Management
=============================

Git software generally has repositories that holds code. Almost, if not all git
software also allows a user to not only contribute to other repositories, but
also have their own repositories that are directly connected to their profile.
In both Rocky Git instances, while we encourage contributions and work on the
many projects within, a personal repository connected only to you is discouraged
in most circumstances.

Below are some general ideas of what is allowed for repository management:

* Allowed: Forking repositories, creating pull requests where needed
* Allowed: Creating repositories (if permitted) in groups you are part of
* Allowed: Creating repositories in your namespace for "people" material (such
           as wiki, pages, and other material)
* Allowed: Creating repositories in your namespace that may potentially move to
           or become a or part of a project within the Rocky ecosystem

* Discouraged: Creating repositories under your namespace for your own use or
               consumption.

If the repository is planned to be moved under a team, SIG or another manner,
this is a valid case for having repositories under your namespace. The user
should request the move when ready by one of the following:

* Submit an issue in a meta repository if applicable
* Open a ticket in the bug tracker if a meta repository does not exist or one
  is not appointed
* Request directly in a public mattermost channel or another applicable medium
  such as email.

Repositories that are found to be personal in nature and do not reflect a
given project, SIG, use for a "people" site or set of material, or repository
(such as a fork) within the Rocky ecosystem may be archived or deleted.

Account Lifecycle
=================

As a general rule of access, the RESF Git Service requires the signing of this
agreement to gain access. For the Rocky Linux GitLab, this is not the case as
the user also needs to be part of the "gitusers" group.

While there are other groups that facilitate more finer grained access into
the various projects and groups, all users (contributors) will need to have
signed this agreement and in the case of GitLab, be part of "gitusers" to login.

Direct sign-ups or local git accounts are not permitted and no exceptions will
be granted.

Obtaining Access to the RESF Forgejo Instance
-------------------------------------------

A user obtains access to the RESF Forgejo instance as long as the following
conditions have been met:

* The user accepts the relevant contributor agreements in Account Services

* The user accepts this agreement

Obtaining Access to the Rocky Linux GitLab
------------------------------------------

A user obtains access to the Rocky Linux git as long as the following 
conditions have been met:

* The user accepts the relevant agreements in Account Services

* The user will be part of a Special Interest Group or other general
  development

* The user or sig sponsor requests access to the "gitusers" group by
  contacting a sponsor in MatterMost - These sponsors can be found in
  the gitusers group in Account Services or at our wiki:
  https://wiki.rockylinux.org/guidelines/git_guidelines/

* The user accepts this agreement

* Upon acceptance and review, user will be added to the "gitusers" group
  in Account Services and their account will then be enabled in the GitLab
  instance.

Requesting Removal of Access
----------------------------

A user that has access to any Rocky git can, at any time, request their account
to be removed. This can be done by logging into the Rocky Linux bug tracker at
https://bugs.rockylinux.org, clicking "Report Issue", selecting the
"Account Services" item, and then selecting "Account Removal Request."

Note that you can also request a full account closure. Please see the
following link for more information.

https://wiki.rockylinux.org/team/infrastructure/idm_pdr/

Revocation of Access
--------------------

A user's access to any Rocky Git can be revoked at any time. Access can be
revoked for but not limited to any of the following reasons:

* Repeated breach of guidelines and expectations as outlined in this agreement

* Breach of the Rocky Open Source Contributor Agreement

* Spam/Bot Accounts - An account that is found to spam or perform bot-like
                      activities will be removed. This also applies to the bug
                      tracking system.

* "Trophy" Accounts - An account that is found just to have access to any Rocky
                      Git that has no plans for contributions and is using it
                      as a way of a status symbol will have their access
                      removed.

                      This also applies to accounts that are solely to make
                      small/trivial changes that does not bring any benefits to
                      the packages, software, and code produced for Rocky as a
                      whole. Pull requests that are found to not improve the
                      state of function of a package, software, or code, as
                      a general rule, are denied.

Acceptance
==========

To access the RESF Git Service, you must accept this agreement to signify
you agree to the guidelines and expectations as laid out above.

To join the "gitusers" group, you must accept this agreement first before a
sponsor can add or request your addition to "gitusers".
