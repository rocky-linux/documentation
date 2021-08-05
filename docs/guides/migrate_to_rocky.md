# Migrating to Rocky 

### Motivation 

As some distros have been decided to be discontinued (Scientific Linux case) and changes in direction of project governance and development cycle (CentOS), a lot of community members have claimed the need to go for more (and real !) community-driven effort. WIth this in mind, Rocky Linux has come to the rescue, in a record time run seeking to solve this community demand.

In Rocky Community, we care about things being done in a serious, funny and responsible way, as reliable as possible. Migration from any other RHEL variant is no different here. Each step, each challenge, will be investigated, dissected to provide the best scenario and satisfaction to our community. Issues may arise, but no panic ladies and gentlemen ! That’s why this technical guide is here, to assist anyone looking for enlightenment when doing migrations. We’ll make our best efforts so one asteroid constellation does not hit another one when switching rings in Saturn’s centurion (yeah, sysadmin folks would say that migration’s are something close to that). 

### General consideration
Before migrate : replicate, test, observe and measure
Main issues when migrating 
There is no 100% safe way to anticipate all or part of the possible issues that may arise when migrating from one RHEL-variant to another, as well any architecture regarding the operation cluster/site trade-offs coming from this migration.

However, still there are some considerations and appointments that community members shoot out based on their experience and knowledge about this. 

#### Be aware of modularity - by Louis Abel

In a scenario where someone runs migrate2rocky script, the modules might be a problem in some random cases. But, it's more recommended to just move, meaning you stand up a new rocky machine side by side with the other CentOS (any other RHEL-variant might work same way, or vary a little bit in the process, this will be covered in the RHEL flavors section) machine, and just migrate that way.

That'd be a good point to bring up at least for migration purposes. For example, we had some folks who ran IPA server, but needed to run ipa-server-upgrade --skip-version-check.

Non-module related, people who run Java on their systems have to run the commands listed here: https://github.com/rocky-linux/rocky-tools/tree/main/migrate2rocky#symbolic-links-to-java-programs-in-etcalternatives-are-gone

Before you start, make sure backups are on place
Keeping all backups in place is one of the most important things for disaster recovery, auditability and critical business data continuity. 

For migration scenarios where reliability is very important, along with operation rollbacks possibility when something goes wrong, changing an OS “in one bone strike” isn’t an easy task, which demands heavy coordination, planning and a fearless approach to succeed.

Don’t put essential and critical data into heavy migration yet

Create single source of truth (SoT) for double checking migration success 

Test disaster recovery with the new migrated environment 
Preparing the environment
Some points to be settled for further checking and investigation:
Multi-machine environment with Vagrant
Software defined network and Software defined storage

Having all of these combined, whenever possible, should be good for representing and simulating the environment and on-site operation architecture as well topologies (disks layouts and controllers, inside rack configuration).

Along with the above points, having a good pair functioning of cluster provisioning and administration such as Warewulf, HPCondor, Grendel, Slurm and others. With this

It is also important to note that all repositories should be disabled but the main OS repos.

#### Investigation sandbox

Side box with Vagrant
Side box with replication via VM cloning
Side box with replication via OS packaging with Packer
Side box with containerization

Along with this, would be critical to ask :

Are there network mounted volumes ?
Are there homogeneous server configurations ?
Are there packages, firmwares as well drivers specific to your hardware and OS version ?
Custom packages?
Internal RPM repos?
How is the process of configuration management taken care of ?
Environments - Active Directory, High Availability, Cron jobs 



Checking if everything went fine
How can we make sure that the migration went smoothly fine, and all the systems are ready to be powered by Rocky ? 

Here are some points and tricks that indicates all migration went down the road nice and steady :

Check /etc/redhat-release
Check for the Rocky header on boot


RHEL flavors - What variants are you coming from ?

The big advantage among all the RHEL variants is the compatibility provided by RPM packages, as well some internals. But, nonetheless, there might exist some differences between one or another variant. This being said, it is quite important to take into consideration the version in use also, as EOL (end-of-life) of OSes and near end of support might face some difficulties concerning repository availability, saving the cases where full-local repositories are held and supported.

For each variant, the community has ran some experiments on migration scenarios and made some recipes for making this process more pleasurable and less painful as possible. The migrate2rocky.sh script has been employed by community members (check Disclaimer section in the beginning). Again, everything is all experimental, nor do we recommend them in official manners and/or means.

Some steps in each variant may vary as well, and when important to notice any of these differences, this will be anticipated and informed as required. 

Scientific Linux

Scientific Linux does not provide version 8 of Enterprise Linux (EL), so, coming from SL may require extra effort to be on page. We have encountered a diversity of considerations when making the switch, as well 

The best scenario here is : 1. Having scripts and configuration management tools for capturing applications and putting all of those in side boxes; 2. Double-checking in between production site and new boxes to see if applications are running smoothly with the new switch
So, the challenge is basic moving the sand castle to the ship without even letting the water touch it 

I would encourage users from any EL7 variant to plan a side-by-side replacement or do a completely new install then attempting an upgrade from EL7 to Rocky 8
CentOS
Oracle Linux
Alma Linux
Springdale
Troubleshooting
Ok, everything went through the roof, a meteorite hitted my data processing site, and Rocky wasn’t able to handle the switch from my dead RHEL variant. What should I do to solve this, from where to start ? 

Doing Root Cause Analysis (RCA) on any sort of problems is the very first step to find what happened. But, accomplishing this does demand some bit of good observation and deduction, as well collecting every data possible (and available by the environment at the moment). System’s facilities tools such as journalctl, trace, top, htop, stop, ctop and BPF provides rich insights on what’s going under the hood all over the system. Is even possible to use external tools to extend the observability factor for systems functionalities. The best remedy is prevention, so, observing everything running and interacting, as much as possible, is the best way to go. 

Capture and save all of the output from the migrate2rocky.sh script. This is useful analysis when asking the community for help. Upload it to a public paste bin to share the link for the community as that much text can be challenging to deal with in the forums and/or mattermost.

The output of the script is the ideal starting place to know where things went wrong and how to fix.


Final moment : Welcome to the Rocky community and enjoy the party :)




### References 

https://www.lisenet.com/2021/migrating-ha-kubernetes-cluster-from-centos-7-to-rocky-linux-8/

https://www.tecmint.com/migrate-centos-8-to-rocky-linux/

https://techviewleo.com/easily-migrate-from-centos-8-to-rocky-linux-8/

https://www.itzgeek.com/how-tos/linux/rocky-linux/how-to-migrate-from-centos-8-to-rocky-linux-8.html

https://linuxiac.com/centos-to-rocky-linux-migration/

https://www.linuxtechi.com/migrate-from-centos-8-to-rocky-linux/

https://morioh.com/p/fe8968fdcb02

https://ostechnix.com/how-to-migrate-to-rocky-linux-8-from-centos-8-linux/

https://www.youtube.com/watch?v=V2erpZgOA78

https://forums.rockylinux.org/t/transition-from-centos-to-rocky/389/6

For migration, consider : 

Essential points to work and investigate later on

The following points present good opportunities for investigating this endeavor and get more technical tasks being achieved, improving the accuracy and potentials for successful migrations.

Main points to be considered when migrating
Describe tools and approaches (script, recipes, playbooks etc) to do migrations
Describe mirrors and repositories 
What was maintained from CentOS, what didn’t
Troubleshooting guidelines (when and if possible) concerning migration
Testing Rocky to leverage it to a more "reliable" scenario, get into stable, as if people seeking to put into production, what trade-offs to observe, as we plan to be bug-by-bug compatible. (Keep asking Rocky Team on this to see if any ideas or technical guidance comes in)
The possibility of building simple tools that can assist people and help with the support
Design and test “testboxes” for isolating applications - VM cloning and configuration management tools can be helpful here - maybe process and applications transplanting to containers and VM’s in the same host (getting the OS to be packaged with Packer is a possibility (?) )
Bulk migration for getting legacy applications inside containers and running on brand new Rocky environment
Ways for investigating edge cases and known failure states would - “During my heavy testing of this script, I did stumble upon some situations where the machine ended up in a unusable state (had to be fixed up manually)”  - Need some review on the steps taken and try to reproduce and document the remediation 
Good to have :
Tool for checking EPEL and OS version compatibility with hardware, mainly for concerning old servers and machines
Consider to get something close to a Docker compose file, where it is possible to bring up all RHEL variants, and apply to all of them migration scripts, populate with example applications, network topology and any other HPC scenario. With this, monitoring the final outcomes and observing (maybe some log collection tool) what was good and what not.
Might be worth while to search mattermost for migate2rocky.sh issues that people have experienced and write up responses to actual known issues/problems with their solutions.
