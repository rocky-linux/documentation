---
title: CVE verification and remediation on Rocky Linux
author: Howard Van Der Wal
contributors: Steven Spencer
tested with: 8, 9
tags:
- security
- CVE
- vulnerability
- patching
ai_contributors: Claude (claude-opus-4-6)
---

## Introduction

Vulnerability scanners frequently flag packages on Rocky Linux systems as unpatched or outdated. In many cases, these are false positives caused by how scanners interpret package version strings. This guide teaches you how to independently verify whether a CVE has been patched in your Rocky Linux packages, understand advisory numbering, address scanner false positives, and apply security updates.

## Prerequisites and assumptions

- A Rocky Linux 8 or 9 system with `dnf` package manager
- Root or `sudo` access
- Familiarity with basic command-line operations
- Optional: `policycoreutils-python-utils` for SELinux context management during remediation

## Checking RPM changelogs for CVE patches

The most reliable way to determine whether a specific CVE has been fixed in an installed package is to inspect its RPM changelog. Red Hat and Rocky Linux package maintainers include CVE identifiers in changelog entries when backporting security fixes.

### Basic changelog query

To check whether a specific CVE has been patched in a package:

```bash
rpm -q --changelog openssl | grep CVE-2024-6119
```

If the CVE has been addressed, you will see a changelog entry similar to:

```text
* Thu Sep 05 2024 Dmitry Belyavskiy <dbelyavs@redhat.com> - 1:3.0.7-28
- Possible denial of service in X.509 name checks
  Resolves: CVE-2024-6119
```

If the command produces no output, the CVE fix is not present in the currently installed version of the package.

### Querying a specific package version

To check the changelog of a package file that is not yet installed:

```bash
rpm -qp --changelog ./openssl-3.0.7-28.el9_4.x86_64.rpm | grep CVE-2024-6119
```

### Querying the repository without installing

To check changelogs for a package available in a repository:

```bash
dnf repoquery --changelog openssl | grep CVE-2024-6119
```

!!! note "Changelog truncation"

    RPM binary packages may have truncated changelogs. The build system trims old entries based on age. If you are searching for an older CVE and the changelog search returns no results, the entry may have been trimmed. Check the source RPM or use the Koji build system web interface, which displays the full changelog at the bottom of each build page.

## Using dnf updateinfo for security advisories

The `dnf updateinfo` subsystem provides a structured view of security advisories affecting your system.

### View a summary of available advisories

```bash
dnf updateinfo
```

Example output:

```text
Updates Information Summary: available
    3 Security notice(s)
        1 Critical Security notice(s)
        2 Important Security notice(s)
    2 Bugfix notice(s)
    1 Enhancement notice(s)
```

### List available security advisories

```bash
dnf updateinfo list security
```

### List already-installed security advisories

```bash
dnf updateinfo list security --installed
```

### Check a specific CVE

To see whether an advisory exists for a specific CVE:

```bash
dnf updateinfo info --cve CVE-2024-6119
```

To check whether the fix is already installed:

```bash
dnf updateinfo list --cve CVE-2024-6119 --installed
```

### Check available security updates without installing

```bash
dnf check-update --security
```

!!! tip "Quick reference"

    | Command | Purpose |
    | --------- | --------- |
    | `dnf updateinfo` | Summary of available advisories |
    | `dnf updateinfo list security` | List available security advisories |
    | `dnf updateinfo list security --installed` | List installed security advisories |
    | `dnf updateinfo info --cve CVE-XXXX-XXXXX` | Details for a specific CVE |
    | `dnf check-update --security` | Check for available security updates |

## Understanding RHSA and RLSA advisory numbering

Rocky Linux security advisories (RLSA) directly mirror Red Hat Security Advisories (RHSA). The advisory numbers are shared, with only the prefix differing.

For example:

- **RHSA-2024:2551** is the Red Hat advisory
- **RLSA-2024:2551** is the corresponding Rocky Linux advisory

### Advisory type prefixes

| Red Hat | Rocky Linux | Meaning |
| --------- | ------------- | --------- |
| RHSA | RLSA | Security Advisory |
| RHBA | RLBA | Bug Fix Advisory |
| RHEA | RLEA | Enhancement Advisory |

The sequential number after the year is shared across all advisory types. RHSA numbers may appear to skip because the intervening numbers belong to RHBA and RHEA advisories.

### Where to find Rocky Linux advisories

Rocky Linux advisories are published at [Rocky Linux Errata](https://errata.rockylinux.org/). You can search by advisory ID, package name, or CVE identifier.

!!! note "Publication timing"

    Rocky Linux advisories may appear later than the corresponding Red Hat advisory. The time lag depends on the Rocky Linux release engineering pipeline. A missing RLSA does not necessarily mean the fix is unavailable. Always check the RPM changelog and the build systems described in the "Monitoring Rocky Linux build systems" section below.

## Module stream version naming

Rocky Linux 8 uses modular repositories (AppStream) where package releases include a module stream identifier in the release string. This identifier is a frequent source of false positives in vulnerability scanners.

### Anatomy of a modular release string

A typical modular package release string looks like:

```text
pcs-0.10.12-6.el8.6.0+7105+f31cb332.x86_64
```

Breaking this down:

| Component | Meaning |
| ----------- | --------- |
| `pcs` | Package name |
| `0.10.12` | Upstream version |
| `6` | RPM release number |
| `el8` | Enterprise Linux 8 |
| `.6.0` | Module stream built for the 8.6 minor release |
| `+7105` | Module build sequence number |
| `+f31cb332` | Context hash identifying the module build |

### Why scanners flag these incorrectly

Vulnerability scanners compare the full NVR (Name-Version-Release) string against their vulnerability databases. When a scanner encounters `el8.6.0` in the release string, it may interpret this as "built for Rocky 8.6" and flag it as outdated compared to a package with `el8.10.0` in its release string.

**This is a false positive.** The module stream suffix (`el8.6.0` versus `el8.10.0`) indicates when the module was built, not the security content of the package. A package with `el8.6.0` in its release string can contain identical security patches to one with `el8.10.0`.

### How to verify

Compare the actual package version and RPM release number (the parts before the module stream suffix), not the full NVR string:

```bash
rpm -q pcs
```

If two systems show:

- `pcs-0.10.12-6.el8.6.0+7105+f31cb332`
- `pcs-0.10.12-6.el8.10.0+1234+abcdef01`

The package version (`0.10.12`) and RPM release (`6`) are identical. These packages contain the same security patches regardless of the module stream suffix.

!!! warning "Scanner configuration"

    If your vulnerability scanner repeatedly flags module stream version differences as vulnerabilities, work with your scanner vendor to add proper Rocky Linux package mapping. Scanners that rely on generic NVD feeds without understanding RHEL-style backporting will produce inaccurate results.

## Identifying Windows-only CVEs

Some CVEs listed in security advisories only affect specific platforms. Vulnerability scanners may flag these on Linux systems even though they have no applicability.

### How to check platform applicability

1. Visit the Red Hat CVE page for the specific CVE:

    ```text
    https://access.redhat.com/security/cve/CVE-XXXX-XXXXX
    ```

2. Look for the **Affected Packages and Issued Red Hat Security Errata** section

3. Check whether the vulnerability applies to your platform

For example, CVE-2024-38472 and CVE-2024-40898 affect the `httpd` package but only on Windows. The Red Hat CVE page explicitly states the platform applicability. These CVEs will never receive a Linux patch because Linux is not affected.

!!! tip "Documenting false positives"

    When you identify a Windows-only CVE flagged on your Linux system, document the finding with the Red Hat CVE page URL as evidence. This documentation is useful when responding to audit findings or vulnerability scan reports.

## Understanding CVSS scoring and backport policies

### Red Hat severity ratings

Red Hat uses a four-level severity scale that does not map directly to CVSS numeric scores:

| Rating | Description |
| -------- | ------------- |
| Critical | Easily exploited remotely by an unauthenticated attacker, leads to system compromise without user interaction |
| Important | Can compromise confidentiality, integrity, or availability of resources |
| Moderate | More difficult to exploit but could still have significant impact |
| Low | Minimal security impact, harder to exploit |

Red Hat performs independent security analysis and may assign a different severity than the NVD CVSS score suggests. This is because Red Hat evaluates how a vulnerability affects their specific products, not just the theoretical impact.

### Backporting policy

Red Hat (and by extension, Rocky Linux) addresses vulnerabilities based on severity:

- **Critical and Important**: Addressed during all support phases, typically as asynchronous updates
- **Moderate** (CVSS base score above 7.0): Also addressed asynchronously
- **Moderate** (CVSS 7.0 or below) and **Low**: Generally addressed during scheduled minor release updates

!!! note "CIQ LTS remediation threshold"

    For CIQ Rocky Linux LTS customers, the remediation threshold is a CVSS base score of 7.0 or higher. CVEs below this threshold are addressed during scheduled updates rather than as individual patches. Check the [CIQ Advisories repository](https://github.com/ctrliq/advisories/tree/main) for CIQ-specific advisory information.

### Checking Red Hat severity ratings

To see how Red Hat rates a specific CVE:

```text
https://access.redhat.com/security/cve/CVE-XXXX-XXXXX
```

The page shows the CVSS score, Red Hat severity rating, and affected products.

## Monitoring Rocky Linux build systems

When a CVE fix has been announced by Red Hat but is not yet available in Rocky Linux repositories, you can track the build and publication pipeline.

### Build system URLs

| System | URL | Purpose |
| -------- | ----- | --------- |
| Koji | [koji.rockylinux.org](https://koji.rockylinux.org/koji/) | Build system for Rocky Linux 8 |
| Peridot | [peridot.build.resf.org](https://peridot.build.resf.org/) | Build system for Rocky Linux 9 |
| Errata | [errata.rockylinux.org](https://errata.rockylinux.org/) | Advisory database |
| Git | [git.rockylinux.org](https://git.rockylinux.org/) | Source package repositories |

### Checking build status in Koji

For Rocky Linux 8 packages:

1. Navigate to [koji.rockylinux.org](https://koji.rockylinux.org/koji/)
2. Search for the package name
3. Click on the latest build to view the full changelog
4. Check whether the CVE fix appears in the changelog

!!! note "Build completion versus repository availability"

    A package appearing in the Koji or Peridot build system does not mean it is available in the official repositories. After a package is built, it goes through testing and staging before publication. Check the official repositories with `dnf check-update` to confirm availability.

## Applying security updates

### Update all security packages

```bash
sudo dnf update --security
```

### Apply a fix for a specific CVE

```bash
sudo dnf update --cve CVE-2024-6119
```

### Apply a specific advisory

```bash
sudo dnf update --advisory RLSA-2024:2551
```

### Minimal security update

To apply the smallest version change that addresses security issues:

```bash
sudo dnf upgrade-minimal --security
```

### Configure automatic security updates

Install the `dnf-automatic` package:

```bash
sudo dnf install dnf-automatic
```

Edit `/etc/dnf/automatic.conf` to enable security-only updates:

```ini
[commands]
upgrade_type = security
apply_updates = yes
```

Enable and start the timer:

```bash
sudo systemctl enable --now dnf-automatic.timer
```

!!! warning "Automatic updates in production"

    Automatic security updates can cause unexpected service restarts or compatibility issues. In production environments, consider using `apply_updates = no` and reviewing available updates manually before applying them.

## End-of-life operating systems

Operating systems that have reached end of life (EOL) no longer receive security patches. If your vulnerability scanner flags CVEs on an EOL system, no upstream fix will be published.

### Key EOL dates

| Distribution | EOL Date |
| ------------- | ---------- |
| CentOS 7 | June 30, 2024 |
| Rocky Linux 8 | May 31, 2029 |
| Rocky Linux 9 | May 31, 2032 |

!!! danger "EOL systems receive no patches"

    Running an EOL operating system in a production environment means accepting all future security vulnerabilities without remediation. The recommended action is migrating to a supported operating system version.

For CIQ LTS customers, extended support may be available beyond standard EOL dates. Contact CIQ for details on extended lifecycle support options.

## Addressing vulnerability scanner false positives

Vulnerability scanners such as Nessus (Tenable), Wazuh, and Nexpose can produce false positives on Rocky Linux for several reasons:

### Common causes of false positives

1. **Module stream version comparison**: Scanners flag `el8.6.0` as outdated compared to `el8.10.0` (see the "Module stream version naming" section)

2. **Upstream version comparison**: Scanners compare against upstream (unpatched) version numbers without accounting for Red Hat or Rocky Linux backporting

3. **Missing Rocky Linux OVAL data**: Some scanners lack proper Rocky Linux vulnerability mappings and fall back to generic NVD feeds

4. **Platform-inapplicable CVEs**: Scanners flag all CVEs in an advisory regardless of operating system applicability

### Verification workflow for scanner findings

When a vulnerability scanner reports a finding, follow this workflow:

1. **Check the RPM changelog** for the CVE:

    ```bash
    rpm -q --changelog <package> | grep CVE-XXXX-XXXXX
    ```

2. **Check dnf updateinfo** for the advisory:

    ```bash
    dnf updateinfo info --cve CVE-XXXX-XXXXX
    ```

3. **Check the Red Hat CVE page** for platform applicability:

    ```text
    https://access.redhat.com/security/cve/CVE-XXXX-XXXXX
    ```

4. **If the CVE is patched**, document the evidence (changelog entry, advisory number) and mark the scanner finding as a false positive

5. **If the CVE is not patched**, check the build systems (Koji or Peridot) for a pending fix, or apply the available security update

!!! tip "Documenting scanner exceptions"

    Maintain a record of verified false positives with their evidence. This documentation helps streamline future vulnerability scan reviews and supports audit compliance processes.

## Conclusion

Effective CVE management on Rocky Linux requires understanding how backporting, advisory numbering, and module stream versioning work. Vulnerability scanners are valuable tools, but their findings must be validated against RPM changelogs, `dnf updateinfo`, and official advisory databases. By following the verification workflow in this guide, you can accurately distinguish between genuine vulnerabilities and false positives.
