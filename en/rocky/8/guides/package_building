Step 4: Produce a Rocky Linux source RPM

Once in a Rocky repository, the contents of a package should correspond directly to its SRPM equivalent.

The debranding should be complete by this point, so a build system (Koji) will be able to point to the repository, grab the source for it, 
and construct our Rocky SRPM using Mock and other RPM tools.

Special attention will have to be paid to the “modular/stream” RPMs in RHEL 8. 
The Modular Build System (MBS) service that interacts with Koji needs to be set up properly to accomodate this.

Particulars of the build config will depend on the answers to steps 2-3 above: What folder(s) will things be in, where will the binary tar file data be located, etc.
