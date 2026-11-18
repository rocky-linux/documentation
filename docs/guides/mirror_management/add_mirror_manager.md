---
title: Adding a Rocky Mirror
contributors: Amin Vakil, Steven Spencer, Ganna Zhyrnova, Brian Clemens
---

# Adding a public mirror to Rocky's Mirror Manager

## Minimal requirements for public mirrors

We always welcome new public mirrors, though they should be well maintained and hosted in a 24/7 data-center-like environment. Available bandwidth should be at least 1 GBit/s. We prefer mirrors offering dual-stack (IPv4 & IPv6). Please do not submit mirrors configured using dynamic DNS. We will also accept slower speeds if you are in a region with only a few mirrors.

Please do not submit mirrors hosted in an Anycast-CDN like Cloudflare, etc., as this can lead to sub-optimal performance with selecting the fastest mirror in `dnf`.

Please note that we cannot accept public mirrors in countries subject to US export regulations. You can find a list of those countries here: <https://www.bis.doc.gov/index.php/policy-guidance/country-guidance/sanctioned-destinations>

The size of a complete `rocky-linux` mirror varies over the release cycle. When a point release ships, the new release is synchronized alongside the one it replaces and the tree reaches around 5.5 TB. The superseded releases move to the vault a few days later, which brings it down to roughly 2.5 TB, and it grows back over the following months as the current releases accumulate updates. Provision for the peak.

While you are catching up, Mirror Manager keeps offering your mirror for the releases it already has and only adds the new one once you have it, so a sync in progress does not take your mirror out of service.

These figures assume your mirror preserves hardlinks. We hardlink identical packages across the repositories, and a mirror that does not keep them uses close to twice the space. If your mirror is much larger than the figures above, see [Checking the size of your mirror](#checking-the-size-of-your-mirror).

Half of the total is debug symbols, so mirrors that do not need them are considerably smaller. See [Reducing the size of your mirror](#reducing-the-size-of-your-mirror).

Our master mirror is `rsync://msync.rockylinux.org/rocky-linux`.
For your first synchronization use a mirror near to you. You can find all official mirrors [here](https://mirrors.rockylinux.org).

The master offers several modules. Most mirrors want `rocky-linux`:

| Module | Contents |
| ------ | -------- |
| `rocky-linux` | Current releases |
| `rocky-vault` | Archived releases |
| `rocky-everything` | Rocky (current and vault) plus the CentOS vault |
| `rocky-sigs` | Special Interest Group content |
| `centos-vault` | CentOS 8 vault |

`rocky-linux` carries the current point release of each supported major version, and briefly the previous one after a new release. Older ones remain as empty directories containing a `README.txt` that points to the vault, so there is no need to exclude them.

Please note that we might restrict access to the official master mirror to official public mirrors in the future. So please consider `rsyncing` from a public mirror close to you if you are running a private mirror. Also local mirrors might be faster to sync from.

## Setting up your mirror

Please set up a cron job to synchronize your mirror periodically and let it run around 6 times a day. But be sure to sync off the hour to help distribute the load over time. If you only check against changes of `fullfiletimelist-rocky` and only do a full sync if this file has changed you can synchronize every hour.

Here are some crontab examples for you:

```bash
#This will synchronize your mirror at 0:50, 4:50, 8:50, 12:50, 16:50, 20:50
50 */6  * * * /path/to/your/rocky-rsync-mirror.sh > /dev/null 2>&1

#This will synchronize your mirror at 2:25, 6:25, 10:25, 14:25, 18:25, 22:25
25 2,6,10,14,18,22 * * * /path/to/your/rocky-rsync-mirror.sh > /dev/null 2>&1

#This will synchronize your mirror every hour at 15 minutes past the hour.
#Only use if you are using our example script
15 * * * * /path/to/your/rocky-rsync-mirror.sh > /dev/null 2>&1
```

For a simple synchronization you can use the following `rsync` command:

```bash
rsync -aqH --delete source-mirror destination-dir
```

Consider using a locking mechanism to avoid running multiple `rsync` jobs simultaneously when we push a new release.

You can also use and modify our example script implementing locking and full sync if required. It can be found at <https://github.com/rocky-linux/rocky-tools/blob/main/mirror/mirrorsync.sh>.

!!! warning "Keep `-H`"

    The master hardlinks identical packages across the repositories. Without `-H`, `rsync` writes every copy as a separate file and your mirror uses close to twice the space it needs. The commands on this page all include it. If you write your own, keep it, and check that your filesystem preserves hardlinks.

After your first complete synchronization check that everything is fine with your mirror. Most importantly, check that all files and directories got synchronized, that your cron job is working properly, and that your mirror is reachable from the public Internet. Double check your firewall rules! To avoid any problems do not enforce http to https redirection.

If you have any questions setting up your mirror join <https://chat.rockylinux.org/rocky-linux/channels/infrastructure>

When you are done head over to the next section and propose your mirror to become public!

## What you need

- An account on <https://accounts.rockylinux.org/>

## Creating a site

Rocky uses Fedora's Mirror Manager for organizing community mirrors.

Access Rocky's Mirror Manager here: <https://mirrors.rockylinux.org/mirrormanager/>

After a successful login, your profile will be on the top right. Select the drop down then click "My sites".

A new page will load listing all sites under the account. The first time it will be empty. Click "Register a new site".

A new page will load with an important Export Compliance statement to read. Then fill out the following information:

- "Site Name"
- "Site Password" - used by the `report_mirror` script, you make this anything you want
- "Organization URL" - Company/School/Organization URL e.g. <https://rockylinux.org/>
- "Private" - Checking this box hides your mirror from public use.
- "User active" - Uncheck this box to temporarily disable this site, it will be removed from public listings.
- "All sites can pull from me?" - Enable all mirror sites to pull from me without explicitly adding them to my list.
- "Comments for downstream siteadmins. Please include your synchronization source here to avoid dependency loops."

Upon clicking "Submit" you will be returned to the main mirror page.

## Configuring the site

Select the drop-down from the main mirror page, then click "My sites".

The account site page will load and the site should be listed. Click on it to go to the Information Site.

All of the options from the last section are listed again. At the bottom of the page are three new options: Admins, Hosts, and Delete site. Click on the "Hosts [add]".

## Creating a host

Fill out the following options that are appropriate for the site:

- "Host name" - required: FQDN of server as seen by a public end user
- "User active" - Uncheck this box to temporarily disable this host, it will be removed from public listings.
- "Country" - required: 2-letter ISO country code
- "Bandwidth" - required: integer megabits/sec, how much bandwidth this host can serve
- "Private" - e.g. not available to the public, an internal private mirror
- "Internet2" - on Internet2
- "Internet2 clients" - serves Internet2 clients, even if private
- "ASN" - Autonomous System Number, used in BGP routing tables. Only if you are an ISP.
- "ASN Clients" - Serve all clients from the same ASN. Used for ISPs, companies, or schools, not personal networks.
- "Robot email" - email address, will receive notice of upstream content updates
- "Comment" - text, anything else you'd like a public end user to know about your mirror
- "Max connections" - Maximum parallel download connections per client, suggested via metalinks.

Click "Create" and it will redirect back to the Information site for the host.

## Updating a host

At the bottom of the Information site, the option for "Hosts" should now display the host title next to it. Click on the name to load the host page. All of the same options from the previous step are listed again. There are new options at the bottom.

- "Site-local Netblocks": Netblocks are used to try to guide an end user to a site-specific mirror. For example, a university might list their netblocks, and the mirror list would return the university-local mirror rather than a country-local mirror. Format is one of 18.0.0.0/255.0.0.0, 18.0.0.0/8, an IPv6 prefix/length, or a DNS hostname. Values must be public IP addresses (no RFC1918 private space addresses). Use only if you are an ISP and/or own a publicly routable netblock!

- "Peer ASNs": Peer ASNs are used to guide an end user on nearby networks to our mirror. For example, a university might list their peer ASNs, and the mirror list would return the university-local mirror rather than a country-local mirror. You must be in the Mirror Manager administrators group in order to create new entries here.

- "Countries Allowed": Some mirrors need to restrict themselves to serving only end users from their country. If you're one of these, list the 2-letter ISO code for the countries you will allow end users to be from. The mirror list will honor this.

- "Categories Carried": Hosts carry categories of software. For Rocky this is "Rocky Linux".

Click on the "[add]" link under "Categories Carried".

### Categories carried

For the Category, select "Rocky Linux" then "Create" to load the URL page. Then click "[add]" to load the "Add host category URL" page. There is one option. Repeat as needed for each of the mirror's supported protocols.

- "URL" - URL (rsync, https, http) pointing to the top directory

Examples:

- `http://rocky.example.com`
- `https://rocky.example.com`
- `rsync://rocky.example.com`

## Wrap up

Once the information is filled out, the site should appear on the mirror list as soon as the next mirror refresh occurs.

## Reducing the size of your mirror

Public mirrors are encouraged to carry everything, but there is no partial rsync module, so if you need a smaller mirror use `--exclude`.

Debug symbols and sources are over half the tree between them:

| Component | At peak | At the low point |
| --------- | ------- | ---------------- |
| `debug` (debug symbols) | 2.7 TB (50%) | 1.1 TB (40%) |
| `source` (SRPMs) | 390 GB (7%) | 270 GB (10%) |

By architecture, counting the debug and source content belonging to each, so these overlap with the figures above:

| Architecture | At peak | At the low point |
| ------------ | ------- | ---------------- |
| `x86_64` | 1.9 TB (36%) | 1.2 TB (44%) |
| `aarch64` | 1.9 TB (35%) | 880 GB (33%) |
| `ppc64le` | 480 GB (9%) | 120 GB (5%) |
| `s390x` | 380 GB (7%) | 100 GB (4%) |
| `riscv64` | 270 GB (5%) | 50 GB (2%) |
| `i686` | 60 GB (1%) | 50 GB (2%) |

The architectures do not add up to the whole tree because the installer images, live media and metadata sit outside them. Shares also shift over the cycle: a freshly released tree carries proportionally less debug content than one that has been accumulating updates for months.

At peak, excluding debug symbols and sources brings the mirror to about 2.4 TB, and also limiting it to `x86_64` and `aarch64` brings it to about 1.8 TB. At the low point those are about 1.3 TB and 1.1 TB:

```bash
rsync -aqH --delete \
  --exclude=debug --exclude=source \
  --exclude=ppc64le --exclude=s390x --exclude=riscv64 \
  source-mirror destination-dir
```

Excludes only affect what is transferred next. Anything already mirrored stays until you delete it, either with `--delete-excluded` or by removing the directories yourself.

Excluding content does not break anything for users. The crawler records which directories your mirror carries, and the mirror list is generated per repository, so your mirror is only offered for the repositories it actually has. A mirror that excludes `debug` is still returned for BaseOS and AppStream, and is simply not among the mirrors returned for debuginfo. Dropping content does not make your mirror appear out of date either, because directories you do not carry are not counted when deciding whether a parent directory is up to date.

Please still note in the comment field for your host that the mirror is partial, so users know what to expect.

## Checking the size of your mirror

Because of the hardlinks, different tools report very different sizes for the same tree. `du` counts each file once and gives the space actually used. File managers and quota tools usually add up directory entries, counting a file once per link, and report close to twice as much.

If your mirror looks much larger than it should, compare the two:

```bash
du -sh  /path/to/rocky
du -shl /path/to/rocky
```

A result about twice the first means the hardlinks are intact and whatever reported the larger figure was counting links. Two similar results mean the hardlinks were not preserved, and the mirror really is using close to twice the space it needs. Re-synchronizing with `-H` onto a filesystem that supports hardlinks recovers the difference.
