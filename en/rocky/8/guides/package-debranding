Steps 2-3: Import source to Git, and replace branding

Each package in RHEL should have a corresponding Rocky Linux Git repository dedicated to it. For example: Rocky Linux will have a bash repository, a python3 repository, a python3-gpg repository, etc. One git repo for each package. Yes, that is a lot of git repositories.

This section will outline some of the major technical hurdles being considered:

The current strategy is to Apply de-brand patches at the same time as import seems viable. So no need for a separate private repo.

Git package/binary strategy
Packages are distributed as specfiles, patches, and the upstream/original source as a tarball (.tar.gz, tar.bz2, etc.). Text files are easy enough in git, but there are different strategies for storing these upstream tar files.

Answer: The agreed-upon strategy is to use a lookaside caching mechanism, just like Fedora and CentOS proper. The one used is called dist-git, and involves a separate script that downloads a tarfile that matches to a checked out git branch.

If this doesn’t work out, git-lfs is also a popular option for binary storage.

Files/Folders, Tags/Branches layout in Git:
Should we stick to the folders/tags/branches layout in git.centos.org? Or something quite different? Should we place debranding metadata with the project, or somewhere else? How about automated/scripted test cases? There is a lot to consider here.

Tentative Answer: Our Git layout will likely mirror certain branches of packages in git.centos.org, but with different names. Debranding metadata will be kept separate, as well as metadata related to modular package builds.
