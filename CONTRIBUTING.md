# Contributing to Rocky Linux Documentation

Thank you for your interest in contributing to Rocky Linux documentation. This guide walks you through everything you need to create, edit, and submit documentation that meets our standards.

## Quick Start

1. Fork the repository
2. Clone your fork locally
3. Set up pre-commit hooks (required)
4. Create or edit documentation
5. Run validation checks
6. Submit a pull request

## Prerequisites

Before contributing, you need:

- A [GitHub account](https://github.com/signup)
- [Git](https://git-scm.com/downloads) installed on your machine
- [Python 3.8+](https://www.python.org/downloads/) for spell checking
- [Node.js](https://nodejs.org/) for markdown linting
- A text editor (see [Local Editors](#local-editors) below)

## Setting Up Your Environment

### Fork and Clone the Repository

1. Navigate to the [Rocky Linux documentation repository](https://github.com/rocky-linux/documentation)
2. Click the **Fork** button in the upper right corner
3. Clone your fork to your local machine:

```bash
git clone https://github.com/YOUR_USERNAME/documentation.git
cd documentation
```

4. Add the upstream repository as a remote:

```bash
git remote add upstream https://github.com/rocky-linux/documentation.git
```

### Install Pre-commit Hooks (Required)

Pre-commit hooks run automatically before each commit to check spelling, markdown formatting, and links. You must set these up before contributing.

1. Install pre-commit:

```bash
pip install pre-commit
```

2. Install the required tools:

```bash
# Install pyspelling for spell checking
pip install pyspelling

# Install aspell dictionaries (varies by OS)
# On Rocky Linux / RHEL / Fedora:
sudo dnf install aspell aspell-en

# On Debian / Ubuntu:
sudo apt-get install aspell aspell-en

# On macOS:
brew install aspell

# Install markdownlint-cli for markdown linting
npm install -g markdownlint-cli

# Install lychee for link checking
# On Rocky Linux / RHEL / Fedora:
sudo dnf install lychee

# On Debian / Ubuntu (via cargo):
cargo install lychee

# On macOS:
brew install lychee
```

3. Install the pre-commit hooks:

```bash
pre-commit install
```

4. Verify the installation by running hooks manually:

```bash
pre-commit run --all-files
```

## Creating New Documentation

### Document Naming

Use lowercase filenames with underscores or hyphens. Keep names short and descriptive:

- `kickstart_rocky.md` - Good
- `HowToInstallRockyLinuxUsingKickstart.md` - Too long
- `ks.md` - Too vague

For translated documents, append the language code before `.md`:

- `kickstart_rocky.md` - English (default)
- `kickstart_rocky.de.md` - German
- `kickstart_rocky.es.md` - Spanish

### Document Location

Place your document in the appropriate directory under `docs/guides/`:

| Topic | Directory |
|-------|-----------|
| Automation tasks | `docs/guides/automation/` |
| Backup solutions | `docs/guides/backup/` |
| Cloud deployments | `docs/guides/cloud/` |
| Content management | `docs/guides/cms/` |
| Communication tools | `docs/guides/communications/` |
| Container technologies | `docs/guides/containers/` |
| Contributing guides | `docs/guides/contribute/` |
| Database systems | `docs/guides/database/` |
| Desktop environments | `docs/guides/desktop/` |
| DNS configuration | `docs/guides/dns/` |
| Text editors | `docs/guides/editors/` |
| Email servers | `docs/guides/email/` |
| File sharing | `docs/guides/file_sharing/` |
| Hardware guides | `docs/guides/hardware/` |
| Interoperability | `docs/guides/interoperability/` |
| Kernel topics | `docs/guides/kernel/` |
| Mirror management | `docs/guides/mirror_management/` |
| Networking | `docs/guides/network/` |
| Package management | `docs/guides/package_management/` |
| Proxy servers | `docs/guides/proxies/` |
| Repositories | `docs/guides/repositories/` |
| Security | `docs/guides/security/` |
| Troubleshooting | `docs/guides/troubleshooting/` |
| Virtualization | `docs/guides/virtualization/` |
| Web servers | `docs/guides/web/` |

If your guide does not fit any existing category, place it in the most relevant directory or ask the documentation team in the [Mattermost Documentation channel](https://chat.rockylinux.org/rocky-linux/channels/documentation).

### Document Structure

Every document must include front matter metadata at the top:

```yaml
---
title: Your Document Title
author: Your Name
contributors: Comma, Separated, Names
tested_with: 8.9, 9.3
tags:
  - relevant
  - tags
  - here
---
```

After the front matter, structure your document with:

1. A brief introduction explaining what the guide covers
2. Prerequisites or requirements
3. Step-by-step instructions
4. Conclusion or summary

### Example Guides

Study these existing guides to understand our formatting and style:

- [Beginner Contributors Guide](https://docs.rockylinux.org/guides/contribute/beginners/) - Good example of contributor-focused documentation
- [Rocky Linux Installation](https://docs.rockylinux.org/guides/installation/) - Example of step-by-step installation guide
- [Anacron](https://docs.rockylinux.org/guides/automation/anacron/) - Example of a focused automation guide

## Formatting Guidelines

### Style Guide

Follow the [Rocky Linux Style Guide](https://docs.rockylinux.org/guides/contribute/style_guide/) for:

- Grammar and punctuation standards
- Voice and tone guidelines
- Accessibility requirements

Key points:

- Use US English spelling
- Use active voice
- Avoid contractions (aids translation)
- Use sentence-style capitalization for headings
- Use serial commas ("apples, oranges, and bananas")

### Markdown Formatting

Follow the [Document Formatting Guide](https://docs.rockylinux.org/guides/contribute/rockydocs_formatting/) for:

- Admonitions (note, warning, tip boxes)
- Code blocks
- Tables
- Lists

Key rules enforced by our linter:

- Use dashes (`-`) for unordered lists, not asterisks
- Include blank lines around headings
- Use fenced code blocks with language identifiers
- Avoid trailing whitespace
- End files with a single newline

### Code Blocks

Always specify the language for syntax highlighting:

````markdown
```bash
dnf install httpd
systemctl enable --now httpd
```
````

For commands where output is shown, use `text` as the language:

````markdown
```text
$ hostname
rocky.example.com
```
````

## Validation Checks

Before committing, the pre-commit hooks automatically run:

1. **Spell check** (pyspelling) - Checks for US English spelling errors
2. **Markdown lint** (markdownlint) - Validates markdown formatting
3. **Link check** (lychee) - Verifies all links are valid

If any check fails, the commit is blocked. Fix the issues and try again.

### Running Checks Manually

Run all checks:

```bash
pre-commit run --all-files
```

Run individual checks:

```bash
# Spell check only
pyspelling

# Markdown lint only
markdownlint docs/

# Link check only
lychee docs/
```

### Adding Words to the Dictionary

If the spell checker flags a valid technical term, add it to `.wordlist.txt` in alphabetical order. Common additions include:

- Rocky Linux specific terms
- Package names
- Technical acronyms
- Command names

## Editing Existing Documentation

1. Sync your fork with upstream:

```bash
git fetch upstream
git checkout main
git merge upstream/main
```

2. Create a branch for your changes:

```bash
git checkout -b fix-typo-in-installation-guide
```

3. Make your edits and commit:

```bash
git add docs/guides/installation.md
git commit -m "Fix typo in installation guide"
```

4. Push and create a pull request:

```bash
git push origin fix-typo-in-installation-guide
```

## Submitting a Pull Request

1. Push your branch to your fork
2. Navigate to the [upstream repository](https://github.com/rocky-linux/documentation)
3. Click **New Pull Request**
4. Select your fork and branch
5. Fill in the pull request template:
   - Describe what you changed
   - Explain why you made the change
   - Reference any related issues

After submission, GitHub Actions runs the same validation checks. The documentation team reviews your pull request and may request changes.

## Local Editors

Choose a markdown editor that suits your workflow:

### Graphical Editors

- [ReText](https://github.com/retext-project/retext) - Free, cross-platform, open source
- [Zettlr](https://www.zettlr.com/) - Free, cross-platform, open source
- [MarkText](https://github.com/marktext/marktext) - Free, cross-platform, open source
- [Remarkable](https://remarkableapp.github.io/) - Linux and Windows, open source
- [VS Code](https://code.visualstudio.com/) - Partially open source, by Microsoft. Recommended extensions: Git Graph, Markdown All in One, Markdown Preview Enhanced, markdownlint

### Terminal Editors

- [NvChad](https://nvchad.com/) - For Neovim users. See our [NvChad setup guide](https://docs.rockylinux.org/books/nvchad/)
- [Doom Emacs](https://github.com/doomemacs/doomemacs) - For Emacs users. Enable the `markdown` module in your config

## Troubleshooting

### Pre-commit Hook Failures

**pyspelling not found**:

```bash
# Install pyspelling
pip install pyspelling

# Verify installation
pyspelling --version
```

**aspell dictionary not found**:

```bash
# Rocky Linux / RHEL / Fedora
sudo dnf install aspell aspell-en

# Debian / Ubuntu
sudo apt-get install aspell aspell-en

# macOS
brew install aspell
```

**markdownlint not found**:

```bash
# Install Node.js first, then:
npm install -g markdownlint-cli

# Verify installation
markdownlint --version
```

**lychee not found**:

```bash
# Rocky Linux / RHEL / Fedora (if available)
sudo dnf install lychee

# Using cargo (Rust package manager)
cargo install lychee

# macOS
brew install lychee
```

### Spell Check False Positives

If the spell checker flags a valid technical term:

1. Verify the term is spelled correctly
2. Add the term to `.wordlist.txt` in alphabetical order
3. Commit the updated wordlist with your changes

### Link Check Timeouts

Some websites block automated requests. If you get false failures:

1. Verify the link works in a browser
2. Check if the URL is already in the exclude list
3. If legitimate, the documentation team may add it to the exclusions

## Getting Help

- **Mattermost**: Join the [Documentation channel](https://chat.rockylinux.org/rocky-linux/channels/documentation) for real-time help
- **GitHub Issues**: Report documentation bugs or suggest improvements
- **Forums**: Visit the [Rocky Linux Forums](https://forums.rockylinux.org) for general questions

## Additional Resources

- [Style Guide](https://docs.rockylinux.org/guides/contribute/style_guide/) - Writing standards
- [Document Formatting](https://docs.rockylinux.org/guides/contribute/rockydocs_formatting/) - Markdown syntax and admonitions
- [Beginner Contributors Guide](https://docs.rockylinux.org/guides/contribute/beginners/) - Detailed walkthrough for new contributors
- [Creating New Documents](https://docs.rockylinux.org/guides/contribute/createnew/) - GitHub-specific instructions
- [Navigation and Structure](https://docs.rockylinux.org/guides/contribute/navigation/) - How the documentation site is organized

## License

Documents contributed to Rocky Linux documentation are published under the [Creative Commons BY-SA 4.0 license](https://creativecommons.org/licenses/by-sa/4.0/). By contributing, you agree to license your work under these terms.
