Rocky Debrand How-To
This explains how to debrand a package for the Rocky Linux distribution.


General Instructions
First, identify the files in the package that need to be changed. They could be text files, image files, or others. You can identify the file(s) by digging into git.centos.org/rpms/PACKAGE/
Develop replacements for these files, but with Rocky branding placed instead. Diff/patch files may be needed as well for certain types of text, depends on the content being replaced.
Replacement files go under https://git.rockylinux.org/patch/PACKAGE/ROCKY/_supporting/
Config file (specifying how to apply the patches) goes in https://git.rockylinux.org/patch/PACKAGE/ROCKY/CFG/*.cfg
Note: Use spaces, not tabs.
When srpmproc goes to import the package to Rocky, it will see the work done in https://git.rockylinux.org/patch/PACKAGE , and apply the stored debranding patches by reading the config file(s) under ROCKY/CFG/*.cfg

The Debrand Config Language
Debranding uses simple proto3 config files. The general format is:

Action {
    file: "OriginalFile"
    with_file: "ROCKY/_supporting/RockyReplaceFile"
}
A simple example to replace a file:

replace {
    file: "redhatlogo.png"
    with_file: "ROCKY/_supporting/rockylogo.png"
}
The file “redhatlogo.png” would be located in under SOURCES/ in the project’s Git repository (and SRPM).


Debrand configuration options
add: Adds a file to the sources using the file directive
delete: Deletes a file from the sources using the file directive
replace: Replaces a file from the sources using the file and with_file directives
patch: Performs a patch based on the diff provided in the file directive (generated using git diff)
spec_change: Allows for spec files to be modified
search_and_replace: Performs a search and replace on a given text for the spec file using the any/starts_with/ends_with (true|false), find (string to find), replace (replacement string), and n (integar, -1 for any) directives.
file: A file can be added to the spec file using the name directive to define the file name, the type directive (such as patch) and then an add option that is true or false
append: Appends to a given field, such as Release with a value directive
changelog: Modifies the change log using author_name, author_email, and message directives
Case Study: Nginx
(note: all example data here is currently in the staging/ area of Rocky Linux Git. We will update it when the projects are moved to the production area)

Let’s go over an example debrand, featuring the Nginx web server package.

The source repository is located here: https://git.centos.org/rpms/nginx

If we browse one of the c8-* branches, we see under SOURCES/ that there is definitely some content that needs to be debranded:

404.html
50x.html
index.html
poweredby.png  (binary file in dist-git, referred to in .nginx.metadata)
These files all refer to Red Hat inc., and must be replaced before they make it to Rocky Linux.

1: Come up with the patches: Each of these files has a Rocky Linux counterpart, and they must be created. Some of this should be done by the Design Team, especially logo work (#Design on chat)

2: Commit patches to the matching patch/PROJECT Git repository : For example, Nginx patches are located here: https://git.rockylinux.org/staging/patch/nginx (staging/ prefix is currently used until our production repos are set up)

3: Develop a matching config file: Our example Nginx has this here: https://git.rockylinux.org/staging/patch/nginx/-/blob/main/ROCKY/CFG/pages.cfg

It looks like this:

replace {
    file: "index.html"
    with_file: "ROCKY/_supporting/index.html"
}

replace {
    file: "404.html"
    with_file: "ROCKY/_supporting/404.html"
}

replace {
    file: "50x.html"
    with_file: "ROCKY/_supporting/50x.html"
}

replace {
    file: "poweredby.png"
    with_file: "ROCKY/_supporting/poweredby.png"
}
4: Test the import: Now, when the upstream is imported, we can check the main Rocky nginx repository and ensure our updates were successful: https://git.rockylinux.org/staging/rpms/nginx/ (again, staging/ group is used only for now)

5: You’re Done! Great! Now do the next one… 😉


More Debrand Config Language
The Nginx example showed just the replace directive, but there are several more available. They are add, patch, and delete.

Here they are, with examples:

# Add a file to the project (file is added to SOURCES/ folder )
add {
    file: "ROCKY/_supporting/add_me.txt"
}

# Apply a .patch file (generated using the Linux "patch" utility)
patch {
    file: "ROCKY/_supporting/002-test-html.patch"
}

# Delete a file from the source project
delete {
    file: "SOURCES/dontneed.txt"
}
And the .patch file example looks like this:

diff --git a/SOURCES/test.html b/SOURCES/test.html
index 8d91ffd..3f76c3b 100644
--- a/SOURCES/test.html
+++ b/SOURCES/test.html
@@ -1,6 +1,6 @@
 <!DOCTYPE html>
 <html>
     <body>
-        <h1>Replace me</h1>
+        <h1>Replace I did!</h1>
     </body>
 </html>
It also supports spec file changes, as it may be necessary. For example, from the anaconda debrand patch repo.

add {
    file: "ROCKY/_supporting/0002-Rocky-disable-cdn-radiobutton.patch"
}

spec_change {
    # Adds a Patch line with the file name as listed above
    file {
        name: "0002-Rocky-disable-cdn-radiobutton.patch"
        type: Patch
        add: true
    }

    # Appends to the end of a field's line, in this case the Release field gets .rocky
    append {
        field: "Release"
        value: ".rocky"
    }

    # Adds to the change log properly
    changelog {
        author_name: "Mustafa Gezen"
        author_email: "mustafa@rockylinux.org"
        message: "Disable CDN and add .rocky to Release"
    }
}
At the end, the spec file should be changed.

Summary:              Graphical system installer
Name:                 anaconda
Version:              33.16.3.26
                      # Our .rocky appears here
Release:              2%{?dist}.rocky

-- snip --

Patch1:               0001-network-do-not-crash-on-infiniband-devices-activated.patch
                      # Look, our patch was added!
                      # Luckily this RPM uses %autosetup, so no %patch lines
Patch2:               0002-Rocky-disable-cdn-radiobutton.patch

-- snip --

# And below the added changelog
%changelog
* Thu Feb 25 2021 Mustafa Gezen <mustafa@rockylinux.org> - 33.16.3.26-2
- Disable CDN and add .rocky to Release

* Thu Oct 22 2020 Radek Vykydal <rvykydal@redhat.com> - 33.16.3.26-2
- network: do not crash on infiniband devices activated in initramfs
  (rvykydal)
  Resolves: rhbz#1890261
