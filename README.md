# Contribution Guide
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-94-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->


## Introduction

_With Rocky Linux emerging as a major RHEL-compatible distribution, this is an exciting time in the open source community. Rocky Linux’s [mission](https://rockylinux.org/community-charter/) is to provide companies and individuals with a **stable foundation of open source software** for their enterprise and HPC needs. We are here to support that mission with excellent documentation._ 

To us, excellent documentation hits these marks:


* Educate users on how to admin this distribution and its associated programs.
* Support users of all skill levels with manuals and troubleshooting guides to make the most of this distribution.
* Apply a consistent standard across all related documents, for ease of reading and translation.
* Keep documentation up to date (and error free) with current versions.
* Allow users to contribute Guides, Docs, Gemstones (scripts and favorite code snippets) and more, to enhance Rocky Linux for fellow users.

We welcome anyone who wants to be part of this mission. No specific degree, years of experience, or company affiliation is required. Be bold! We promise, you won’t break anything even if you fumble your first attempt.

## License

Documents written by the _rocky linux documentation team_ are published under the Creative Commons-BY-SA license. This means you are free to copy, distribute and transform the works, while respecting the author's rights.

* **BY**: Attribution. You must cite the name of the original author.
* **SA**: Share Alike.

[Creative Commons-BY-SA license](https://creativecommons.org/licenses/by-sa/4.0/)

The documents and their sources are freely downloadable from:

* [https://docs.rockylinux.org](https://docs.rockylinux.org/)
* [https://github.com/rocky-linux/documentation](https://github.com/rocky-linux/documentation)

Our media sources are hosted at github.com. You'll find the source code repository where the version of this document was created.

## Technical requirements

_Our standards for Rocky documentation._

### Style Guide

The RL [Style Guide](https://docs.rockylinux.org/guides/contribute/style_guide/) outlines standards for the wording within your document. 

### GitHub  

Rocky Linux uses GitHub to manage its code and files, including documentation files. Login to GitHub and follow the official [Rocky Linux documentation repository](https://github.com/rocky-linux/documentation). 


### Markdown

Documentation is welcome in whatever format you are used to creating. It does not need to be perfect, just submit what you have and the team will give you feedback to help get it in line with our voice and tone. 

That said, RL Documentation uses Markdown as the standard. It is easy to learn and use. Run a text converter on your content or start from scratch with this [basic writing and formatting guide](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax). For more information on writing markdown with proper formatting, see [our guide](https://docs.rockylinux.org/guides/contribute/rockydocs_formatting). 

As you become a regular contributor, you’ll need to create a **local repository**. See our [guide](https://docs.rockylinux.org/guides/contribute/beginners) for how to install a Markdown editor and create a local repository on your home computer.


## Contribution Process

_The actual process of reporting an issue, revising, or creating a doc. Please see special notes afterward about translations, links, and meta content._


### Report an issue

Maybe you’ve found a broken link or incorrect information while exploring the Rocky docs. This is called an **issue**, and we want to know about it. You can mention it on the Mattermost Documentation channel, or visit GitHub and make a proper issue report. GitHub has [a handy guide](https://docs.github.com/en/issues/tracking-your-work-with-issues/creating-an-issue) for how to create an issue.


### Submit an update

_Add a missing word, correct an error, or clarify a confusing bit of text. You won’t break anything because someone will review your contribution before it goes live. Here is the basic process._



1. Start on the page you want to update on [https://docs.rockylinux.org/](https://docs.rockylinux.org/). 

    Click the “Edit” pencil in the upper right corner of the document. You will be taken to the original document stored on GitHub. 

    The first time you contribute to the RL repository, you will be prompted with a green button to “**Fork** this **repository** and propose changes.” This creates a duplicate copy of the RL repository where you make your suggested edits. Click the green button and continue.

2. Make your changes

    Follow the existing Markdown formatting. Make the necessary change.

3. Propose changes

    At the bottom of the page, write a brief description in the title of the block entitled Propose changes.

    Then click Propose changes, which will **Commit** your changes to a completed document within your forked repository.

4. Review changes 

    Now you can look at what you’ve done, line by line. If you missed anything, back up to the previous page and correct it again (you’ll have to start over), then click Propose Changes again.

    Once the doc is the way you want it, click the green button that says Create Pull Request. This provides one more chance to double check your changes and confirm the doc is ready.

5. Create Pull Request

    So far you have been working in your own repository. Next you submit it to the documentation team to merge your version into the main version of the document.

    Click the green button that says Create Pull Request, which sends it to the RL documentation team for review.

6. Wait

    Once the RL team reviews your request, they will respond in one of three ways.

    * Accept and merge your PR
    * Comment with feedback and ask for changes
    * Deny your PR with explanation

    If you have to make changes, you will suddenly understand why you need a local repository. The team can [talk you through](https://chat.rockylinux.org/rocky-linux/channels/documentation) what to do next. In good news, it’s still fixable.

Need more in-depth explanation? Here are the [same directions](https://docs.rockylinux.org/guides/contribute/beginners) with more elaboration under the heading, "Submit an update."

Success? Welcome to the team, you are officially a Rocky Linux documentation contributor. Your profile will be added to the contributor list at the bottom of this document shortly.


### Become a frequent contributor

For more than a word or two of occasional edits, we recommend that you [setup a local repository](https://docs.rockylinux.org/guides/contribute/createnew) on your own machine. From there, you can revise documentation from your clone of the RL repository, Commit it to your online GitHub repository, and then create Pull Requests to merge with the main repository.

Advanced users may wish to create a complete documentation server on your local Linux workstation or VM. We have guides to set that up with [Docker](https://docs.rockylinux.org/guides/contribute/localdocs/rockydocs_web_dev/) or [LXD](https://docs.rockylinux.org/guides/contribute/localdocs/mkdocs_lsyncd/). We also have a [fast documentation system](https://docs.rockylinux.org/guides/contribute/localdocs/local_docs/) with special caveats if you are using Python on the same server.


### Submit a new document

_Rocky Linux documentation includes guides, books, labs, and [gemstones](https://docs.rockylinux.org/gemstones/). Your original contributions are welcome in any of these categories._


#### Meta

Please include the following **meta** information at the top of all new documentation:

---

title: Document title 

author: the author of the source (English) version of the document.

contributors: a comma separated list of contributors to the source document.

tested with: a comma separated list of versions, for example 8.6, 9.0

tags: 

  - displayable tags

  - these are also searchable

  - they are two space indented and start with a "-" as shown here

  - generally, they should be one word

---


#### Formatting

To add more advanced elements to your Markdown-formatted document beyond text, visit the [formatting guide](https://docs.rockylinux.org/guides/contribute/rockydocs_formatting/). This covers Admonitions, Tables, Quotes, and more.


#### Contribute

The process for [submitting original content](https://docs.rockylinux.org/guides/contribute/createnew)  is similar to updating an existing document from your local repository. Create a new document within your Markdown editor, Commit it to your GitHub repository, then submit a Pull Request to merge into the main branch of the repository. The documentation leads will decide where the new document will live.


## Special Notes


### Links

Links can be internal (other docs within our domain), external (publicly hosted URLs), or lab-based (used as examples within your document).

The format for all links within the documentation is square brackets around the descriptive name or label: 

[our site] followed by your link in parenthesis: (https://example.com)

To help lab-based URLs pass our automatic URL checker, we have created a list of excluded names you may use. You may request that a new exclusion be added. An editor may adjust your lab-based URL, or add an exclusion if they think it is warranted.

Please note the following IEEE recommendation on naming local networks [RFC #8375 Special-Use Domain 'home.arpa.'](https://www.rfc-editor.org/rfc/rfc8375.html) published in May 2018.


* home.arpa
* example.com
* site.com
* site1.com
* site2.com
* apache-server
* nginx-server
* your-server-ip
* your-server-hostname
* localhost


### Translation 


#### CrowdIn

We are adding to these docs in new languages at the speed of getting translators on board. Seeking contributors for this area especially. We use [CrowdIn](https://crowdin.com/) for updates. 


#### Translation and Meta content

Translators, if you find a word in the source document that does not translate well into your language, or an error that prevents a perfect translation, please fix that in the source document and make a Pull Request. In that case, please add yourself as a contributor in the meta content of that document. 

However, unless you modify the source document, please do not modify the meta content.

The place where we do want to acknowledge you is in the all-contributors section--at the bottom of this page. This is a list of everyone who has been part of this documentation project, whether creating content, spotting and fixing errors, or translating. Translators, you may add yourself (or [request to be added](https://chat.rockylinux.org/rocky-linux/channels/documentation)) here. We appreciate your contribution! 


## Communication channel

_For reporting issues, asking questions, getting support, and getting to know the documentarians._

For general questions about installing and using the distro, visit our [community forums](https://forums.rockylinux.org). For questions about the behind-the-scenes stuff like documentation, we have other channels.


### Mattermost

To ask real-time questions, create a profile on the [Mattermost](https://mattermost.com/) server, then navigate to the Rocky Linux [General](https://chat.rockylinux.org/rocky-linux/channels/town-square) or [Documentation](https://chat.rockylinux.org/rocky-linux/channels/documentation) channel--or whichever channel seems appropriate to your question. You should get a response within hours if not right away.

Welcome aboard! Meet the rest of our awesome contributors below: ([emoji key](https://allcontributors.org/docs/en/emoji-key)):
<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/wsoyinka"><img src="https://avatars.githubusercontent.com/u/23367125?v=4?s=100" width="100px;" alt="wale soyinka"/><br /><sub><b>wale soyinka</b></sub></a><br /><a href="#projectManagement-wsoyinka" title="Project Management">📆</a> <a href="#maintenance-wsoyinka" title="Maintenance">🚧</a> <a href="#content-wsoyinka" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/sspencerwire"><img src="https://avatars.githubusercontent.com/u/4265212?v=4?s=100" width="100px;" alt="sspencerwire"/><br /><sub><b>sspencerwire</b></sub></a><br /><a href="#projectManagement-sspencerwire" title="Project Management">📆</a> <a href="#maintenance-sspencerwire" title="Maintenance">🚧</a> <a href="#content-sspencerwire" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://ezequiel.works"><img src="https://avatars.githubusercontent.com/u/1215780?v=4?s=100" width="100px;" alt="Ezequiel Bruni"/><br /><sub><b>Ezequiel Bruni</b></sub></a><br /><a href="#maintenance-EzequielBruni" title="Maintenance">🚧</a> <a href="#content-EzequielBruni" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ambaradan"><img src="https://avatars.githubusercontent.com/u/87865413?v=4?s=100" width="100px;" alt="ambaradan"/><br /><sub><b>ambaradan</b></sub></a><br /><a href="#translation-ambaradan" title="Translation">🌍</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/alemorvan"><img src="https://avatars.githubusercontent.com/u/3603739?v=4?s=100" width="100px;" alt="Antoine Le Morvan"/><br /><sub><b>Antoine Le Morvan</b></sub></a><br /><a href="#content-alemorvan" title="Content">🖋</a> <a href="#translation-alemorvan" title="Translation">🌍</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jimcat8"><img src="https://avatars.githubusercontent.com/u/86754294?v=4?s=100" width="100px;" alt="tianci li"/><br /><sub><b>tianci li</b></sub></a><br /><a href="#content-jimcat8" title="Content">🖋</a> <a href="#translation-jimcat8" title="Translation">🌍</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Student"><img src="https://avatars.githubusercontent.com/u/19212264?v=4?s=100" width="100px;" alt="student"/><br /><sub><b>student</b></sub></a><br /><a href="#content-Student" title="Content">🖋</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/NezSez"><img src="https://avatars.githubusercontent.com/u/17833417?v=4?s=100" width="100px;" alt="NezSez"/><br /><sub><b>NezSez</b></sub></a><br /><a href="#content-NezSez" title="Content">🖋</a> <a href="#ideas-NezSez" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/justasojourner"><img src="https://avatars.githubusercontent.com/u/66750169?v=4?s=100" width="100px;" alt="justasojourner"/><br /><sub><b>justasojourner</b></sub></a><br /><a href="#content-justasojourner" title="Content">🖋</a> <a href="#ideas-justasojourner" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://shrug.pw/"><img src="https://avatars.githubusercontent.com/u/680198?v=4?s=100" width="100px;" alt="Neil Hanlon"/><br /><sub><b>Neil Hanlon</b></sub></a><br /><a href="#content-NeilHanlon" title="Content">🖋</a> <a href="#maintenance-NeilHanlon" title="Maintenance">🚧</a> <a href="#ideas-NeilHanlon" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/pajamian"><img src="https://avatars.githubusercontent.com/u/92609?v=4?s=100" width="100px;" alt="Peter Ajamian"/><br /><sub><b>Peter Ajamian</b></sub></a><br /><a href="#content-pajamian" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://github.com/Bakrog"><img src="https://avatars.githubusercontent.com/u/3700397?v=4?s=100" width="100px;" alt="Flávio Siqueira Prado"/><br /><sub><b>Flávio Siqueira Prado</b></sub></a><br /><a href="#translation-Bakrog" title="Translation">🌍</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Norio4"><img src="https://avatars.githubusercontent.com/u/25744143?v=4?s=100" width="100px;" alt="Norio4"/><br /><sub><b>Norio4</b></sub></a><br /><a href="#translation-Norio4" title="Translation">🌍</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.volted.net/"><img src="https://avatars.githubusercontent.com/u/40760290?v=4?s=100" width="100px;" alt="Sébastien Pascal-Poher"/><br /><sub><b>Sébastien Pascal-Poher</b></sub></a><br /><a href="#translation-sjpp" title="Translation">🌍</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ltrecanao"><img src="https://avatars.githubusercontent.com/u/76416245?v=4?s=100" width="100px;" alt="Lucas Trecanao"/><br /><sub><b>Lucas Trecanao</b></sub></a><br /><a href="#translation-ltrecanao" title="Translation">🌍</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/calderds"><img src="https://avatars.githubusercontent.com/u/37597884?v=4?s=100" width="100px;" alt="calderds"/><br /><sub><b>calderds</b></sub></a><br /><a href="#content-calderds" title="Content">🖋</a> <a href="https://github.com/rocky-linux/documentation/pulls?q=is%3Apr+reviewed-by%3Acalderds" title="Reviewed Pull Requests">👀</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/execion"><img src="https://avatars.githubusercontent.com/u/49331776?v=4?s=100" width="100px;" alt="execion"/><br /><sub><b>execion</b></sub></a><br /><a href="#translation-execion" title="Translation">🌍</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/lillolollo"><img src="https://avatars.githubusercontent.com/u/730814?v=4?s=100" width="100px;" alt="lillolollo"/><br /><sub><b>lillolollo</b></sub></a><br /><a href="#content-lillolollo" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/batashi"><img src="https://avatars.githubusercontent.com/u/6708191?v=4?s=100" width="100px;" alt="Ahmed alBattashi"/><br /><sub><b>Ahmed alBattashi</b></sub></a><br /><a href="#content-batashi" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/StackKorora"><img src="https://avatars.githubusercontent.com/u/42156355?v=4?s=100" width="100px;" alt="StackKorora"/><br /><sub><b>StackKorora</b></sub></a><br /><a href="#content-StackKorora" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/3xtant"><img src="https://avatars.githubusercontent.com/u/13157282?v=4?s=100" width="100px;" alt="3xtant"/><br /><sub><b>3xtant</b></sub></a><br /><a href="#content-3xtant" title="Content">🖋</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/almrv"><img src="https://avatars.githubusercontent.com/u/18002181?v=4?s=100" width="100px;" alt="almrv"/><br /><sub><b>almrv</b></sub></a><br /><a href="#translation-almrv" title="Translation">🌍</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://hbjy.dev/"><img src="https://avatars.githubusercontent.com/u/22327045?v=4?s=100" width="100px;" alt="Hayden"/><br /><sub><b>Hayden</b></sub></a><br /><a href="#content-hbjydev" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://linuxguideandhints.com/"><img src="https://avatars.githubusercontent.com/u/11469736?v=4?s=100" width="100px;" alt="Louis Abel"/><br /><sub><b>Louis Abel</b></sub></a><br /><a href="#content-nazunalika" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.threemysticapes.com/"><img src="https://avatars.githubusercontent.com/u/787308?v=4?s=100" width="100px;" alt="Ron"/><br /><sub><b>Ron</b></sub></a><br /><a href="#content-tikicoder" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://aminvakil.com/"><img src="https://avatars.githubusercontent.com/u/12948692?v=4?s=100" width="100px;" alt="Amin Vakil"/><br /><sub><b>Amin Vakil</b></sub></a><br /><a href="#content-aminvakil" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/prasad15"><img src="https://avatars.githubusercontent.com/u/12524081?v=4?s=100" width="100px;" alt="K.Prasad"/><br /><sub><b>K.Prasad</b></sub></a><br /><a href="#content-prasad15" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/IncorrigiblyBelligerent"><img src="https://avatars.githubusercontent.com/u/77499937?v=4?s=100" width="100px;" alt="IncorrigiblyBelligerent"/><br /><sub><b>IncorrigiblyBelligerent</b></sub></a><br /><a href="#content-IncorrigiblyBelligerent" title="Content">🖋</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jaijunior"><img src="https://avatars.githubusercontent.com/u/53584770?v=4?s=100" width="100px;" alt="Jairo Nonato Júnior"/><br /><sub><b>Jairo Nonato Júnior</b></sub></a><br /><a href="#content-jaijunior" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://saifhalila.github.io/"><img src="https://avatars.githubusercontent.com/u/10274380?v=4?s=100" width="100px;" alt="Saif Eddine Halila"/><br /><sub><b>Saif Eddine Halila</b></sub></a><br /><a href="#content-saifhalila" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/DrCool2"><img src="https://avatars.githubusercontent.com/u/32649803?v=4?s=100" width="100px;" alt="DrCool2"/><br /><sub><b>DrCool2</b></sub></a><br /><a href="#content-DrCool2" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/bzuelly"><img src="https://avatars.githubusercontent.com/u/15173198?v=4?s=100" width="100px;" alt="codedude"/><br /><sub><b>codedude</b></sub></a><br /><a href="#content-bzuelly" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://cubeops.net/"><img src="https://avatars.githubusercontent.com/u/16643747?v=4?s=100" width="100px;" alt="Graham"/><br /><sub><b>Graham</b></sub></a><br /><a href="#content-gp-Airee" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/theputta"><img src="https://avatars.githubusercontent.com/u/22313054?v=4?s=100" width="100px;" alt="Aditya Putta"/><br /><sub><b>Aditya Putta</b></sub></a><br /><a href="#content-theputta" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/yangxuan74"><img src="https://avatars.githubusercontent.com/u/20755861?v=4?s=100" width="100px;" alt="yangxuan74"/><br /><sub><b>yangxuan74</b></sub></a><br /><a href="#content-yangxuan74" title="Content">🖋</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/xpseudonym"><img src="https://avatars.githubusercontent.com/u/5032475?v=4?s=100" width="100px;" alt="Morgan Read"/><br /><sub><b>Morgan Read</b></sub></a><br /><a href="#content-xpseudonym" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/9p4"><img src="https://avatars.githubusercontent.com/u/17993169?v=4?s=100" width="100px;" alt="9p4"/><br /><sub><b>9p4</b></sub></a><br /><a href="#content-9p4" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/liquidspikes"><img src="https://avatars.githubusercontent.com/u/5150291?v=4?s=100" width="100px;" alt="Alex Zimmerman"/><br /><sub><b>Alex Zimmerman</b></sub></a><br /><a href="#content-liquidspikes" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/viscountstyx"><img src="https://avatars.githubusercontent.com/u/46753436?v=4?s=100" width="100px;" alt="Andrew Faulkner"/><br /><sub><b>Andrew Faulkner</b></sub></a><br /><a href="#content-viscountstyx" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/televi"><img src="https://avatars.githubusercontent.com/u/3333248?v=4?s=100" width="100px;" alt="Todd Levi"/><br /><sub><b>Todd Levi</b></sub></a><br /><a href="#content-televi" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/tahder"><img src="https://avatars.githubusercontent.com/u/5017393?v=4?s=100" width="100px;" alt="tahder"/><br /><sub><b>tahder</b></sub></a><br /><a href="#content-tahder" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/tacahiroy"><img src="https://avatars.githubusercontent.com/u/76614?v=4?s=100" width="100px;" alt="Takahiro Yoshihara"/><br /><sub><b>Takahiro Yoshihara</b></sub></a><br /><a href="#content-tacahiroy" title="Content">🖋</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/garthus1"><img src="https://avatars.githubusercontent.com/u/12569720?v=4?s=100" width="100px;" alt="Gerard Arthus"/><br /><sub><b>Gerard Arthus</b></sub></a><br /><a href="#content-garthus1" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/HadManySons"><img src="https://avatars.githubusercontent.com/u/3620051?v=4?s=100" width="100px;" alt="HadManySons"/><br /><sub><b>HadManySons</b></sub></a><br /><a href="#content-HadManySons" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/bmayfi3ld"><img src="https://avatars.githubusercontent.com/u/563214?v=4?s=100" width="100px;" alt="Brandon Mayfield"/><br /><sub><b>Brandon Mayfield</b></sub></a><br /><a href="#content-bmayfi3ld" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/astauntonie"><img src="https://avatars.githubusercontent.com/u/25220665?v=4?s=100" width="100px;" alt="Anthony Staunton"/><br /><sub><b>Anthony Staunton</b></sub></a><br /><a href="#content-astauntonie" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://blog.iclouds.work/"><img src="https://avatars.githubusercontent.com/u/21030747?v=4?s=100" width="100px;" alt="whg517"/><br /><sub><b>whg517</b></sub></a><br /><a href="#content-whg517" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/MrSkribb"><img src="https://avatars.githubusercontent.com/u/44088296?v=4?s=100" width="100px;" alt="MrSkribb"/><br /><sub><b>MrSkribb</b></sub></a><br /><a href="#content-MrSkribb" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/payagej"><img src="https://avatars.githubusercontent.com/u/20729061?v=4?s=100" width="100px;" alt="jules"/><br /><sub><b>jules</b></sub></a><br /><a href="#content-payagej" title="Content">🖋</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/bittin"><img src="https://avatars.githubusercontent.com/u/43197?v=4?s=100" width="100px;" alt="bittin"/><br /><sub><b>bittin</b></sub></a><br /><a href="#content-bittin" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://ichibariki.com/"><img src="https://avatars.githubusercontent.com/u/4787502?v=4?s=100" width="100px;" alt="ichibariki"/><br /><sub><b>ichibariki</b></sub></a><br /><a href="#content-ichibariki" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/bernipuig"><img src="https://avatars.githubusercontent.com/u/12746940?v=4?s=100" width="100px;" alt="Bernat Puigdomenech Pascual"/><br /><sub><b>Bernat Puigdomenech Pascual</b></sub></a><br /><a href="#content-bernipuig" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/netzwergehh"><img src="https://avatars.githubusercontent.com/u/79668910?v=4?s=100" width="100px;" alt="Dennis Körner"/><br /><sub><b>Dennis Körner</b></sub></a><br /><a href="#content-netzwergehh" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/bezunartea"><img src="https://avatars.githubusercontent.com/u/13090619?v=4?s=100" width="100px;" alt="Pedro Bezunartea López"/><br /><sub><b>Pedro Bezunartea López</b></sub></a><br /><a href="#translation-bezunartea" title="Translation">🌍</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/danopogac"><img src="https://avatars.githubusercontent.com/u/8373145?v=4?s=100" width="100px;" alt="Daniel Pogac"/><br /><sub><b>Daniel Pogac</b></sub></a><br /><a href="#content-danopogac" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Oats"><img src="https://avatars.githubusercontent.com/u/18314360?v=4?s=100" width="100px;" alt="oats"/><br /><sub><b>oats</b></sub></a><br /><a href="#content-Oats" title="Content">🖋</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="http://alexharden.org/"><img src="https://avatars.githubusercontent.com/u/8281207?v=4?s=100" width="100px;" alt="Alex Harden"/><br /><sub><b>Alex Harden</b></sub></a><br /><a href="#content-aharden" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://jorp.xyz/"><img src="https://avatars.githubusercontent.com/u/18096435?v=4?s=100" width="100px;" alt="Jordan Pisaniello"/><br /><sub><b>Jordan Pisaniello</b></sub></a><br /><a href="#content-jorp" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://hennig.mse.ufl.edu/"><img src="https://avatars.githubusercontent.com/u/8710634?v=4?s=100" width="100px;" alt="Richard Hennig"/><br /><sub><b>Richard Hennig</b></sub></a><br /><a href="#content-rhennig" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/caffenix"><img src="https://avatars.githubusercontent.com/u/64636709?v=4?s=100" width="100px;" alt="caffenix"/><br /><sub><b>caffenix</b></sub></a><br /><a href="#content-caffenix" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://manickathan.ch/"><img src="https://avatars.githubusercontent.com/u/3255070?v=4?s=100" width="100px;" alt="Lento Manickathan"/><br /><sub><b>Lento Manickathan</b></sub></a><br /><a href="#content-lento234" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://www.depts.ttu.edu/cac/"><img src="https://avatars.githubusercontent.com/u/2364484?v=4?s=100" width="100px;" alt="Alan Sill"/><br /><sub><b>Alan Sill</b></sub></a><br /><a href="#content-alansill" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://bandism.net/"><img src="https://avatars.githubusercontent.com/u/22633385?v=4?s=100" width="100px;" alt="Ikko Ashimine"/><br /><sub><b>Ikko Ashimine</b></sub></a><br /><a href="#content-eltociear" title="Content">🖋</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/williamperron"><img src="https://avatars.githubusercontent.com/u/15235219?v=4?s=100" width="100px;" alt="William Perron"/><br /><sub><b>William Perron</b></sub></a><br /><a href="#content-williamperron" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/romh87"><img src="https://avatars.githubusercontent.com/u/81292426?v=4?s=100" width="100px;" alt="Roman Gherta"/><br /><sub><b>Roman Gherta</b></sub></a><br /><a href="#content-romh87" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://cybertrouble.com"><img src="https://avatars.githubusercontent.com/u/12031564?v=4?s=100" width="100px;" alt="Yiğit can BAŞALMA"/><br /><sub><b>Yiğit can BAŞALMA</b></sub></a><br /><a href="#content-yigitbasalma" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/markooff"><img src="https://avatars.githubusercontent.com/u/24265888?v=4?s=100" width="100px;" alt="markooff"/><br /><sub><b>markooff</b></sub></a><br /><a href="#content-markooff" title="Content">🖋</a> <a href="#translation-markooff" title="Translation">🌍</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/dengwenbin"><img src="https://avatars.githubusercontent.com/u/20312281?v=4?s=100" width="100px;" alt="Deng Wenbin"/><br /><sub><b>Deng Wenbin</b></sub></a><br /><a href="#translation-dengwenbin" title="Translation">🌍</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/alikates"><img src="https://avatars.githubusercontent.com/u/59802505?v=4?s=100" width="100px;" alt="alikates"/><br /><sub><b>alikates</b></sub></a><br /><a href="#content-alikates" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/hopnux"><img src="https://avatars.githubusercontent.com/u/110078361?v=4?s=100" width="100px;" alt="hopnux"/><br /><sub><b>hopnux</b></sub></a><br /><a href="#translation-hopnux" title="Translation">🌍</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://www.breakingpitt.es"><img src="https://avatars.githubusercontent.com/u/10740572?v=4?s=100" width="100px;" alt="Pedro Garcia Rodriguez"/><br /><sub><b>Pedro Garcia Rodriguez</b></sub></a><br /><a href="#translation-BreakingPitt" title="Translation">🌍</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://laurenzkruty.de"><img src="https://avatars.githubusercontent.com/u/37706897?v=4?s=100" width="100px;" alt="Lau"/><br /><sub><b>Lau</b></sub></a><br /><a href="#content-LauKr" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://www.meteocontrol.cn"><img src="https://avatars.githubusercontent.com/u/11520535?v=4?s=100" width="100px;" alt="Serge Croisé"/><br /><sub><b>Serge Croisé</b></sub></a><br /><a href="#content-SergeCroise" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/bamtests"><img src="https://avatars.githubusercontent.com/u/17178592?v=4?s=100" width="100px;" alt="bamtests"/><br /><sub><b>bamtests</b></sub></a><br /><a href="#content-bamtests" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://social.linux.pizza/@jahway603"><img src="https://avatars.githubusercontent.com/u/64485701?v=4?s=100" width="100px;" alt="jahway603"/><br /><sub><b>jahway603</b></sub></a><br /><a href="#content-jahway603" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/bertronika"><img src="https://avatars.githubusercontent.com/u/42844753?v=4?s=100" width="100px;" alt="Nejc Bertoncelj"/><br /><sub><b>Nejc Bertoncelj</b></sub></a><br /><a href="#content-bertronika" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/bakerds"><img src="https://avatars.githubusercontent.com/u/16193241?v=4?s=100" width="100px;" alt="Dan Baker"/><br /><sub><b>Dan Baker</b></sub></a><br /><a href="#content-bakerds" title="Content">🖋</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://git.sr.ht/%7Equartsize/"><img src="https://avatars.githubusercontent.com/u/37243063?v=4?s=100" width="100px;" alt="Laura Hild"/><br /><sub><b>Laura Hild</b></sub></a><br /><a href="#content-quartsize" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Grammaresque"><img src="https://avatars.githubusercontent.com/u/119525559?v=4?s=100" width="100px;" alt="Grammaresque"/><br /><sub><b>Grammaresque</b></sub></a><br /><a href="#content-Grammaresque" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/rawkakani"><img src="https://avatars.githubusercontent.com/u/7724090?v=4?s=100" width="100px;" alt="Rawk Akani"/><br /><sub><b>Rawk Akani</b></sub></a><br /><a href="#content-rawkakani" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/nm583"><img src="https://avatars.githubusercontent.com/u/121867206?v=4?s=100" width="100px;" alt="nm583"/><br /><sub><b>nm583</b></sub></a><br /><a href="#content-nm583" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/MrPaulAR"><img src="https://avatars.githubusercontent.com/u/3765696?v=4?s=100" width="100px;" alt="MrPaulAR"/><br /><sub><b>MrPaulAR</b></sub></a><br /><a href="#content-MrPaulAR" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cybernet"><img src="https://avatars.githubusercontent.com/u/125879?v=4?s=100" width="100px;" alt="cybernet"/><br /><sub><b>cybernet</b></sub></a><br /><a href="#content-cybernet" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Muph0"><img src="https://avatars.githubusercontent.com/u/10765858?v=4?s=100" width="100px;" alt="Jan Kytka"/><br /><sub><b>Jan Kytka</b></sub></a><br /><a href="#content-Muph0" title="Content">🖋</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="http://howtotechwriting.com/"><img src="https://avatars.githubusercontent.com/u/38929299?v=4?s=100" width="100px;" alt="Mario"/><br /><sub><b>Mario</b></sub></a><br /><a href="#content-doble-eme" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/gannazhyrnova"><img src="https://avatars.githubusercontent.com/u/112796922?v=4?s=100" width="100px;" alt="Ganna Zhyrnova"/><br /><sub><b>Ganna Zhyrnova</b></sub></a><br /><a href="#translation-gannazhyrnova" title="Translation">🌍</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Demalpheus"><img src="https://avatars.githubusercontent.com/u/28327241?v=4?s=100" width="100px;" alt="Travis W"/><br /><sub><b>Travis W</b></sub></a><br /><a href="#content-Demalpheus" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://g.dev/rana_tej_singh"><img src="https://avatars.githubusercontent.com/u/58101587?v=4?s=100" width="100px;" alt="Tej Singh Rana"/><br /><sub><b>Tej Singh Rana</b></sub></a><br /><a href="#content-Tej-Singh-Rana" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/captain-Arvoy"><img src="https://avatars.githubusercontent.com/u/99230514?v=4?s=100" width="100px;" alt="Aditya Roshan Dash"/><br /><sub><b>Aditya Roshan Dash</b></sub></a><br /><a href="#content-captain-Arvoy" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.qyecst.cn"><img src="https://avatars.githubusercontent.com/u/13901864?v=4?s=100" width="100px;" alt="qyecst"/><br /><sub><b>qyecst</b></sub></a><br /><a href="#content-qyecst" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/msmit5"><img src="https://avatars.githubusercontent.com/u/55892653?v=4?s=100" width="100px;" alt="Matt"/><br /><sub><b>Matt</b></sub></a><br /><a href="#content-msmit5" title="Content">🖋</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/zdover23"><img src="https://avatars.githubusercontent.com/u/1445107?v=4?s=100" width="100px;" alt="zdover23"/><br /><sub><b>zdover23</b></sub></a><br /><a href="#content-zdover23" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/YadlaMani"><img src="https://avatars.githubusercontent.com/u/133841094?v=4?s=100" width="100px;" alt="Mani Yadla"/><br /><sub><b>Mani Yadla</b></sub></a><br /><a href="#content-YadlaMani" title="Content">🖋</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/DavisBarnabas"><img src="https://avatars.githubusercontent.com/u/39591292?v=4?s=100" width="100px;" alt="Dave_Barnabas"/><br /><sub><b>Dave_Barnabas</b></sub></a><br /><a href="#content-DavisBarnabas" title="Content">🖋</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
