# Git Workflow for Documentation: Git, Git-Cola, and Atom

It should be noted at the outset that this is by no means a definitive workflow. There are many git workflow options that are possible. You may not find this one to your liking and that is fine. You might find parts of this workflow that you like and other parts that just don't work for you. That's fine too. This is one method, and the author is hopeful that others will share there Git workflows as well, providing the Rocky Linux community that wants to contribute to the documentation, a wealth of options to do so.

## The Components

This particular workflow uses the following components:

* A personal fork of the documentation repository found [here](https://github.com/rocky-linux/documentation)
* A local cloned copy of the repository on a Linux workstation
* Git-Cola: a visual client for git branching and staging
* The Atom editor. (optional)

!!! Note
    The Atom editor is optional. If you choose to use a different markdown editor, then simply ignore all of the Atom steps.

## Prerequisites and Assumptions

* A Rocky Linux desktop
* Familiarity with the command line
* A Github account with SSH key access

## Installing Repositories

Only a couple of repositories are really required. The EPEL (Extra Packages for Enterprise Linux) and the Atom editor repository.

To install the EPEL:

`sudo dnf install epel-release`

Next, we need the GPG key for Atom and the repository:

`sudo rpm --import https://packagecloud.io/AtomEditor/atom/gpgkey`

and then:

`sudo sh -c 'echo -e "[Atom]\nname=Atom Editor\nbaseurl=https://packagecloud.io/AtomEditor/atom/el/7/\$basearch\nenabled=1\ngpgcheck=0\nrepo_gpgcheck=1\ngpgkey=https://packagecloud.io/AtomEditor/atom/gpgkey" > /etc/yum.repos.d/atom.repo'`

Then update the system:

`sudo dnf update`

## Installing Packages

Run the following command to install the packages we need with `dnf`:

`sudo dnf install git git-cola`

There will be a number of other packages installed as dependencies so simply answer 'Y' to allow the installation.

Next, install the Atom editor:

`sudo dnf install atom`

## Forking the Rocky Linux Documentation Repository

You will need your own fork of the repository. This will become one of your Git remotes for this workflow.

We are already assuming that you've created your Github account, have SSH key access and are logged in to [Documentation](https://github.com/rocky-linux/documentation).

On the right-hand side of the page, click on "Fork" shown here:

![Documentation Fork](images/gw_fork.png)

When this completes, you should have a fork with a URL that has your username in it. If your Git username was "alphaomega" then the URL would be:

```
https://github.com/alphaomega/documentation
```

## Cloning a Local copy of the Repository

Next we need a local copy of the repository, which is easy enough to do. Again, from the Rocky Linux [Documentation](https://github.com/rocky-linux/documentation), look for the green Code button and click on it:

![Documentation Code](images/gw_greencode.png)

Once open, click on SSH and then copy the URL:

![Documentation Copy SSH](images/gw_sshcopy.png)

On your Linux workstation in a terminal window, enter the following at the command line:

`git clone `

And then paste the URL into the command line so you should have this when done:

`git clone git@github.com:rocky-linux/documentation.git`

When this command is completed, you should now have a local copy of the documentation repository. This creates a directory called "documentation" in your home directory:

```
home:~/documentation
```

## Setting Up Git-Cola

Next, we need to set up Git-Cola. We need to open the "documentation" repository we just created locally, and we need to set the remotes. You can set your remotes with git via the command line as well, but I find this method easier, because for me, I want the Rocky Linux remote to be called something different than "origin" which is what it will name it by default. For me, I think of my fork, as the "origin" and Rocky Linux as the "upstream". You may disagree.

<<todo: Get screen shot of Git-Cola opening the documentation repository>>

When you first open Git-Cola, it asks you to select your repository. You could have several on your machine, but the one you are looking for is the one called "documentation". So click on this one and open it.

<todo: Get screen shots of the Git-Cola remotes setup>>

Once you have your repository open, setup the remotes by clicking on `File` and `Edit Remotes`.

By default, it will already show you your Rocky Linux remote as "origin". To change this, simply click in the field, back space over the top of "origin", replace it with "upstream" and click "Save"

Next, we actually want to create a new remote that is your fork. Click the green plus sign (+) in the left-hand corner of the bottom of the screen and a new remote dialog will open. Type "origin" for the name, and then, assuming our Github username is "alphaomega" again, your URL will look like this:

```
git@github.com:alphaomega/documentation.git
```
Save this and you are done.

### Testing that your Workflow will actually workflow

Do this all from the command line:

Change into your documentation directory:

`cd documentation`

Then type:

`git pull upstream main`

This will test that you have everything setup and working to pull from Rocky Linux upstream.

If there are no problems, next type the following:

`git push origin main`

This will test access to your fork of the Rocky Linux documentation. If there are no errors, then this command can be strung together in the future with:

`git pull upstream main && git push origin main`

This command should be run before any branches are created or any work is done, to keep your branches in sync.

## A Note about Atom and Git-Cola and why the author uses both

The Atom editor has integration with Git and Github. In fact, you can use Atom without the need for Git-Cola at all. That said, the visualizations that Git-Cola provide are clearer from the author's view. The editor features in Atom far outweigh those that are specifically designed as markdown editors (again, the author's opinion). If you so choose, you can eliminate the need for Git-Cola and simply use Atom if you like.

I use Git-Cola for setting up the remotes (as we have already seen), branching, and committing changes. Atom is used as an editor and markdown preview only. Pushes and pulls are done from the command line.

## Branching with Git-Cola

You always want to create a branch by using the "main" as the template. Make sure that "main" is selected in the "Branches" listing on the right-hand side of Git-Cola, then click "Branch" top menu item and "Create". Type a name for your new branch.

!!! Note
    When naming branches, consider using descriptive names. These will help add clarity when you push them upstream. For instance, the author uses an "rl_" prefix when creating a new document, and then appends the a descriptive short name for what the document is. For edits, the author uses "edit_" as the prefix followed by a short name about what the edit is for.

As an example, below you can see the "Branches" listing, which shows "rl_git_workflow":

![Git-Cola Branches](images/gw_gcbranches.png)

As you create and save your changes in Atom, you will see the "Unstaged Changes" listing in the Git view change:

![Atom Unstaged](images/gw_atomunstaged.png)

These changes also show up in Git-Cola under the "Status" in the left-hand window:

![Git-Cola Unstaged](images/gw_gitcolaunstaged.png)
