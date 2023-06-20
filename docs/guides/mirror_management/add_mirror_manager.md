---
title: Adding a Rocky Mirror
contributors: Amin Vakil, Steven Spencer
---

# Adding a public mirror to Rocky's mirror manager

## Minimal requirements for public mirrors

We always welcome new public mirrors. But they should be well maintained and hosted in a 24/7 data center like environment. Available bandwidth should be at least 1 GBit/s. We prefer mirrors offering dual-stack (IPv4 & IPv6). Please do not submit mirrors configured using dynamic DNS. If you are offering a mirror in a region that has only few mirrors, we will also accept slower speeds.

Please do not submit mirrors which are hosted in a Anycast-CDN like Cloudflare, etc. as this can lead to sub-optimal performance with the selection of fastest mirror in `dnf`.

Please note that we are not allowed to accept public mirrors in countries subject to US export regulations. You can find a list of those countries here: [https://www.bis.doc.gov/index.php/policy-guidance/country-guidance/sanctioned-destinations](https://www.bis.doc.gov/index.php/policy-guidance/country-guidance/sanctioned-destinations)

As of this writing (late 2022), storage space requirements for mirroring all current and past Rocky Linux releases is about 2 TB.

Our master mirror is `rsync://msync.rockylinux.org/rocky/mirror/pub/rocky/` .
For your first synchronization use a mirror near to you. You can find all official mirrors [here](https://mirrors.rockylinux.org).

Please note that we might restrict access to the official master mirror to official public mirrors in the future. So please consider `rsyncing` from a public mirror close to you if you are running a private mirror. Also local mirrors might be faster to sync from.

## Setting up your mirror

Please set up a cron job to synchronize your mirror periodically and let it run around 6 times a day. But be sure to sync off the hour to help distribute the load over time. If you only check against changes of `fullfiletimelist-rocky` and only do a full sync if this file has changed you can synchronize every hour.

Here are some crontab examples for you:

```
#This will synchronize your mirror at 0:50, 4:50, 8:50, 12:50, 16:50, 20:50
50 */6  * * * /path/to/your/rocky-rsync-mirror.sh > /dev/null 2>&1

#This will synchronize your mirror at 2:25, 6:25, 10:25, 14:25, 18:25, 22:25
25 2,6,10,14,18,22 * * * /path/to/your/rocky-rsync-mirror.sh > /dev/null 2>&1

#This will synchronize your mirror every hour at 15 minutes past the hour.
#Only use if you are using our example script
15 * * * * /path/to/your/rocky-rsync-mirror.sh > /dev/null 2>&1
```

For a simple synchronization you can use the following `rsync` command:

```
rsync -aqH --delete source-mirror destination-dir
```
Consider using a locking mechanism to avoid running more than one `rsync` job simultaneously when we push a new release.

You can also use and modify our example script implementing locking and full sync if required. It can be found at [https://github.com/rocky-linux/rocky-tools/blob/main/mirror/mirrorsync.sh](https://github.com/rocky-linux/rocky-tools/blob/main/mirror/mirrorsync.sh).

After your first complete synchronization check that everything is fine with your mirror. Most importantly check all files and dirs got synchronized, your cron job is working properly and your mirror is reachable from the public Internet. Double check your firewall rules! To avoid any problems do not enforce http to https redirection.

If you have any questions setting up your mirror join https://chat.rockylinux.org/rocky-linux/channels/infrastructure

When you are done head over to the next section and propose your mirror to become public!

## What You Need
* An account on https://accounts.rockylinux.org/

## Creating a site

Rocky uses Fedora's Mirror Manager for organizing community mirrors.

Access Rocky's Mirror Manager here: https://mirrors.rockylinux.org/mirrormanager/

After a successful login, your profile will be on the top right. Select the drop down then click "My sites".

A new page will load listing all of the sites under the account. The first time it will be empty. Click "Register a new site".

A new page will load with an important Export Compliance statement to read. Then fill out the following information:

* "Site Name"
* "Site Password" - used by `report_mirrors` script, you make this anything you want
* "Organization URL" - Company/School/Organization URL e.g. https://rockylinux.org/
* "Private" - Checking this box hides your mirror from public use.
* "User active" - Uncheck this box to temporarily disable this site, it will be removed from public listings.
* "All sites can pull from me?" - Enable all mirror sites to pull from me without explicitly adding them to my list.
* "Comments for downstream siteadmins. Please include your synchronization source here to avoid dependency loops."

Upon clicking "Submit" you will be returned to the main mirror page.

## Configuring the site

From the main mirror page, select the drop down then click "My sites".

The account site page will load and the site should be listed. Click on it to go to the Information Site.

All of the options from the last section are listed again. At the bottom of the page are three new options: Admins, Hosts, and Delete site. Click on the "Hosts [add]".

## Create new host

Fill out the following options that are appropriate for the site:

* "Host name" - required: FQDN of server as seen by a public end user
* "User active" - Uncheck this box to temporarily disable this host, it will be removed from public listings.
* "Country" - required: 2-letter ISO country code
* "Bandwidth" - required: integer megabits/sec, how much bandwidth this host can serve
* "Private" - e.g. not available to the public, an internal private mirror
* "Internet2" - on Internet2
* "Internet2 clients" - serves Internet2 clients, even if private
* "ASN - Autonomous System Number, used in BGP routing tables. Only if you are an ISP.
* "ASN Clients? - Serve all clients from the same ASN. Used for ISPs, companies, or schools, not personal networks.
* "Robot email" - email address, will receive notice of upstream content updates
* "Comment" - text, anything else you'd like a public end user to know about your mirror
* "Max connections" - Maximum parallel download connections per client, suggested via metalinks.

Click "Create" and it will redirect back to the Information site for the host.

## Update host

At the bottom of the Information site, the option for "Hosts" should now display the host title next to it. Click on the name to load the host page. All of the same options from the previous step are listed again. There are new options at the bottom.

* "Site-local Netblocks":  Netblocks are used to try to guide and end user to a site-specific mirror. For example, a university might list their netblocks, and the mirrorlist CGI would return the university-local mirror rather than a country-local mirror. Format is one of 18.0.0.0/255.0.0.0, 18.0.0.0/8, an IPv6 prefix/length, or a DNS hostname. Values must be public IP addresses (no RFC1918 private space addresses). Use only if you are an ISP and/or own a publicly routable netblock!

* "Peer ASNs":  Peer ASNs are used to guide an end user on nearby networks to our mirror. For example, a university might list their peer ASNs, and the mirrorlist CGI would return the university-local mirror rather than a country-local mirror. You must be in the MirrorManager administrators group in order to create new entries here.

* "Countries Allowed":  Some mirrors need to restrict themselves to serving only end users from their country. If you're one of these, list the 2-letter ISO code for the countries you will allow end users to be from. The mirrorlist CGI will honor this.

* "Categories Carried":  Hosts carry categories of software. Example Fedora categories include Fedora and Fedora Archive.

Click on the "[add]" link under "Categories Carried".

### Categories Carried

For the Category, select "Rocky Linux" then "Create" to load the URL page. Then click "[add]" to load the "Add host category URL" page. There is one option. Repeat as needed for each of the mirrors supported protocols.

* "URL" - URL (rsync, https, http) pointing to the top directory

Examples:
* `http://rocky.example.com`
* `https://rocky.example.com`
* `rsync://rocky.example.com`


## Wrap up

Once the information is filled out, the site should appear on the mirror list as soon as the next mirror refresh occurs.
