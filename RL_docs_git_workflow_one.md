# Rock Linux Git Workflow - Linux Workstation using Git, Tig and SSH Keys

# Introduction

There are many ways for you to setup a Git workflow that will work with the Rock Linux documentation site. This version, stays with the command-line and uses Tig for Git staging. It also uses SSH keys for work with accessing Git, which avoids logins and two-factor authentication-both of which you should have setup too. This particular workflow is not meant to be the be-all end-all of Git workflows for Rocky Linux. It is simply one way that some of you may find useful.  While this version is written specifically for uses on a Linux Workstation, I'm hopeful that it will either be edited to include other operating systems, or new documents will be created that will deal with other operating systems.

## Prerequisites

* A Linux workstation with Git, Tig and the Openssh-client installed
* Knowledge of the command-line and specifically, git commands
* We assume you have already created a Fork of the Rock Linux documentation

### Setting Up the SSH Keys

If you use SSH keys to access other services or servers, then you may already have an SSH key setup. You can verify this by checking to make sure that you have a .ssh folder in your home folder and that inside, it has at minimum a private and public key. If your .ssh folder exists and inside it you have a file that has a .pub extension, then you should be ready to go and you can skip ahead to ** Adding Your SSH Key to Git **. 

To setup your ssh key, from the command-line on your Linux workstation do: 

`ssh-keygen -t rsa` 

This will show you something line this:

```
Generating public/private rsa key pair.
Enter file in which to save the key (/home/yourname/.ssh/id_rsa):
```
.  ..  id_rsa  id_rsa.pub
Go ahead and hit 'Enter' here to accept the path. The prompts will now show you this:

`Enter passphrase (empty for no passphrase): `

Go ahead and hit 'Enter' for no passphrase. Next you will be prompted for the pass
phrase again:

`Enter same passphrase again:`
.  ..  id_rsa  id_rsa.pub
Hit 'Enter' again to accept the empty passphrase.

Verify that you have the public and private key installed in your .ssh

`ls -a .ssh/`

Which should show at minimum: 

`.  ..  id_rsa  id_rsa.pub`

If it does, then congratulations! You are ready to move on to the next step.

### Adding Your SSH Key to Git

By now, you should have already set up your Git username and password and your two-factor authentication. That will all be required in August 2021, so it's a good idea to have all of that ready to go. Using SSH keys bypasses the need for username, password and two-factor authentication when doing work from the command-line and THAT can be a huge time saver.

To add your SSH Key to Git do the following:

1. Do a `more .ssh/id_rsa.pub` and copy all of th e contents of the key into your clipboard. Make sure you get all of it, but avoid any trailing spaces.
2. Go to the [[Git Key Section]](https://github.com/settings/keys) and click on the "New SSH Key" button and paste the contents of your public key.
3. Save your changes

Now test your key by doing the following from our Linux workstation command-line:

`ssh -T git@github.com`

If you've entered everything correctly, you should get back a message like this:

`Hi yourname! You've successfully authenticated, but Github does not provide shell access.`

If you get that message, it's time to continue to the next step.

### Setting Up Your Remotes

By default, when you setup the Rocky Linux remote, it wants to assign it the name "origin", but you don't want this. The reason is that the Rocky Linux documentation is your "upstream" and your "origin" is going to be your fork. It makes perfect sense once you think about it. You aren't going to be making direct changes to the Rocky Linux documentation site, your going to make your changes to your fork (origin) and will request the changes be merged by doing a pull reques.

To setup the Rocky Linux documentation site as the upstream, just do the following:

1. Go to the Rocky Linux documentation site and click on the Green "Code" button. 
2. Under "Clone" make sure you click on the "SSH" option
3. Copy the entire URL, which should be something like (and probably exactly like) this:`git@github.com:rocky-linux/documentation.git`
4. From your Linux workstation command-line enter the following: `git remote add upstream git@github.com:rocky-linux/documentation.git`

Now we want to setup your fork as the origin:

1. Go to the URL for your fork of the Rocky Linux documentation and click on the Green "Code" button"
2. Under "Clone" make sure you click on the "SSH" option
3. Copy the entire URL, which should look something like (but not exactly like) this: `git@github.com:yourname/documentation.git`
4. From your Linux workstation command-line enter the following: `git remote add origin git@github.com:yourname/documentation.git`

Great! You should now have both remotes setup. You can test this by entering the following: 

`git remote -v`

Which should return something like this:

```
origin	git@github.com:yourname/documentation.git (fetch)
origin	git@github.com:yourname/documentation.git (push)
upstream	git@github.com:rocky-linux/documentation.git (fetch)
upstream	git@github.com:rocky-linux/documentation.git (push)
```

### Keeping Things Synced

This really all that your are going to be doing with your upstream and origin setup. Everything else will be handled with a branch and mergin. This allows you to keep the main branch and your fork up-to-date even while you are working on a more lengthy project. No need to submit multiple pull requests for something that might take you some time to finish and you don't want to get out of sync with upstream nor do you want your fork to get out of sync. For this reason, each time you get in to do work always enter the following command:

`git pull upstream main && git push origin main`

So we pull from upstream (Rocky Linux) the main branch, and push the same back to our origin (Personal Fork)

## Working On Documentation

Now that we have our environment setup in a way that works, we are ready to do some work. We don't, however, want to make changes to our local main branch. Instead, we want to create a branch for our work so that if it takes multiple days to complete, we can still keep the upstream and origin in sync with each other. When we are done with our work, we can then merge it back into our main and submit a PR, staging this all with Tig. Here we go!

### Creating a Branch and Adding a Document

So as stated, when we want to work on something, we want to do it in a branch. To create a branch, think about what you are going to be working on. For instance, for this project, a branch called rl_git_workflow was created. 

To do this, on your Linux workstation you would enter:

`git checkout -b rl_git_workflow`

Now we can create the document we want to work on, in this case a document called RL_docs_git_workflow_one.md was created. At some point, we want to add it to the branch using git like so:

`git add RL_docs_git_workflow_one.md`

This makes the branch aware of the file. Now just keep working on the file until you are done with it.



