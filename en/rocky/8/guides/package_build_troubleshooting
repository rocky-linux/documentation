## Intro - What needs to be done  

The area we need help the most right now, and the easiest way to contribute, is to help troubleshoot failing package builds.

We’re rebuilding CentOS 8.3 as “practice”, so we can figure out any issues that crop up with our official Rocky build ahead of time. We are documenting any errors we find in the packages and how to fix them (to make it build). This documentation will help our release engineering team when it comes time to do official builds.

## Helping with the debug effort:  

Once you are familiar with Mock, and especially with debugging its output, you can begin looking at failing packages. Some of this information is also on the Mock HowTo page linked above.

Find a failing package on the newest build pass failures page (currently Build Pass 10: https://wiki.rockylinux.org/en/team/development/Build_Order/Build_Pass_10_Failure)

Make sure the package hasn’t already been looked at and/or fixed: https://wiki.rockylinux.org/en/team/development/Package_Error_Tracking

Let other debuggers know what you’re working on! We don’t want to duplicate effort. Hop on chat.rockylinux.org (#dev/packaging channel) and let us know!

Set your mock program up with the most recent configs that we are using (linked above). You can use it to attempt the build in the same way as we do (with external dependencies, extra repos, etc.)

Investigate the error(s): You can use your own mock, as well as the log files from when the build failed, located here: https://rocky.lowend.ninja/RockyDevel/MOCK_RAW/

Figure out what’s going on, and how to fix it. It may take the form of special mock settings, or a patch added to the program + specfile. Report your findings to the #Dev/Packaging channel, and someone will record them on the Wiki Package_Error_Tracking page linked above.

The idea is to shrink the Build Failures, and grow the Package_Error_Tracking page. If necessary, we will commit build fixes to our patch repo for the different packages located here: https://git.rockylinux.org/staging/patch.
