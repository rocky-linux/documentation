---
title: Adding a public mirror to Rocky's mirror manager
---

# Adding a public mirror to Rocky's mirror manager

Rocky uses Fedora's Mirror Manager for organizing community mirrors.

## What You Need
* An account on https://accounts.rockylinux.org/


## Creating a site

Access Rocky's Mirror Manager here: https://mirrors.rockylinux.org/mirrormanager/

After a successful login, your profile will be on the top right. Select the drop down then click "My sites".

A new page will load listing all of the sites under the account. The first time will be empty. Click "Register a new site".

A new page will load with an important Export Compliance statement to read. Then fill out the following information:
* "Site Name"
* "Site Password" - used by report_mirrors script, you make this anything you want
* "Organization URL" - Company/School/Organization URL e.g. https://rockylinux.org/
* "Private" - Checking this box hides this site from public use.
* "User active" - Uncheck this box to temporarily disable this site, it will be removed from public listings.
* "All sites can pull from me?" - Enable all mirror sites to pull from me without explicitly adding them to my list.
* "Comments for downstream siteadmins"

Upon clicking "Submit" you will be returned to the main mirror page.

## Configuring the site

From the main mirror page, select the drop down then click "My sites".

The account site page will load and the site should be listed. Click it to go to the Information Site.

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
* "ASN - Autonomous System Number, used in BGP routing tables.
* "ASN Clients? - Serve all clients from the same ASN. Used for ISPs, companies, or schools, not personal networks.
* "Robot email" - email address, will receive notice of upstream content updates
* "Comment" - text, anything else you'd like a public end user to know about your mirror
* "Max connections" - Maximum parallel download connections per client, suggested via metalinks.

Click "Create" and it will redirect back to the Information site for the host.

## Update host

At the bottom of the Information site, the option for "Hosts" should now display the host title next to it. Click on the name to load the host page. All of the same options from the previous step are listed again. There are new options at the bottom.

* "Site-local Netblocks":  Netblocks are used to try to guide and end user to a site-specific mirror. For example, a university might list their netblocks, and the mirrorlist CGI would return the university-local mirror rather than a country-local mirror. Format is one of 18.0.0.0/255.0.0.0, 18.0.0.0/8, an IPv6 prefix/length, or a DNS hostname. Values must be public IP addresses (no RFC1918 private space addresses). 

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

Sync your mirror from rsync://msync.rockylinux.org
