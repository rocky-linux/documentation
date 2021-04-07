Step 1: Obtain the Source
This is fairly straightforward. If you want to re-build RHEL 8, you need the source to RHEL 8. There are 2 main ways to do this:

Download source RPM files on a RHEL machine via yum/dnf
Copy them from https://git.centos.org (which are identical to RHEL and have tagged versions)
The packaging team has decided to go with option #2: copying from CentOS Git. This minimizes potential legal questions with RHEL subscription terms, and is a simple operation to perform. SRPM extraction can be used in the future in case of any issues with the CentOS Git site.

Tools are now being developed to perform this step in an automated fashion. CentOS (and Fedora) use an MQ messaging solution to indicate when new commits are made to a repository. We intend to consume those published messages as well to get alerted when we should build a new package.

We have news that https://git.centos.org will be the actual commit location for RHEL sources in the future, so we should be in good company!

Future Doc: There will be another document explaining exactly what is in the CentOS Git branches, how to navigate, etc.
