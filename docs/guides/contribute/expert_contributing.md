---
title: An expert's guide to contributing
author: Howard Van Der Wal
contributors:
ai_contributors: Claude (claude-opus-4-6)
tags:
  - contributing
  - documentation
  - guide
---

## AI usage disclosure

This document was created with the assistance of AI. All content has been reviewed, tested, and verified by a human author. The author takes full responsibility for the accuracy and correctness of this document.

## Welcome

Thank you for your interest in contributing to the Rocky Linux documentation. Whether you are writing new guides, translating existing content, or editing for clarity, every contribution matters and is deeply valued by the community.

This guide is for contributors who want to set up a full local validation environment with spell checking, markdown linting, and link checking tools. **Setting up these tools is entirely optional, but recommended for first-time contributors.** If you are new to contributing, the [Beginner contributors guide](beginners.md) is a great place to start. You can also edit documentation directly on GitHub without installing anything locally.

No matter your experience level, the Rocky Linux community is here to help. If you have questions, run into problems, or just want guidance on where to start, join the [Mattermost Documentation channel](https://chat.rockylinux.org/rocky-linux/channels/documentation). Someone will be happy to help you get started.

## Quick start

1. Fork the [Rocky Linux Documentation repository](https://github.com/rocky-linux/documentation)
2. Clone your fork locally
3. Set up pre-commit hooks (optional but recommended)
4. Create or edit documentation
5. Run validation checks
6. Submit a pull request

## Prerequisites

Before setting up the local validation environment, you need:

- A [GitHub account](https://github.com/signup)
- [Git](https://git-scm.com/downloads) installed on your machine
- [Python 3.8+](https://www.python.org/downloads/) for spell checking
- [Node.js](https://nodejs.org/) for markdown linting
- A text editor (see the local editors section below)

## Fork and clone the repository

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

## Setting up your environment

### Alternative tooling

The setup instructions in this section describe one approach to documentation validation using pre-commit hooks and command-line tools. There are other methods available to check your markdown documents, before submitting them as a PR.

If you already use a terminal-based editor (Neovim, Emacs, Helix, etc.) with integrated linting tools, you can continue using your existing workflow. Tools like:

- [markdownlint](https://github.com/DavidAnson/markdownlint) or [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) - Available as editor plugins for real-time markdown linting
- [vale](https://github.com/errata-ai/vale) - Prose linter that can enforce style guide rules
- [harper-ls](https://github.com/Automattic/harper) - Grammar checker with LSP support
- [ltex-ls](https://github.com/valentjn/ltex-ls) - LanguageTool-based grammar and spell checking via LSP

These tools provide the same validation capabilities and can be configured to match the Rocky Linux documentation standards. The key requirement is that your contributions pass the automated CI checks when you submit a pull request, regardless of which tools you use locally.

### Local editors

Choose a markdown editor that suits your workflow:

#### Graphical editors

- [ReText](https://github.com/retext-project/retext) - Free, cross-platform, open source
- [Zettlr](https://www.zettlr.com/) - Free, cross-platform, open source
- [MarkText](https://github.com/marktext/marktext) - Free, cross-platform, open source
- [Remarkable](https://remarkableapp.github.io/) - Linux and Windows, open source
- [Zed](https://zed.dev/) - Free, cross-platform, open source, written in Rust. Plugins available for vale, marksman, harper-ls, and markdownlint
- [VS Code](https://code.visualstudio.com/) - Partially open source, by Microsoft. Recommended extensions: Git Graph, Markdown All in One, Markdown Preview Enhanced, markdownlint

#### Terminal editors

- [NvChad](https://nvchad.com/) - For Neovim users. See our [NvChad setup guide](../../../books/nvchad/index.md)
- [Doom Emacs](https://github.com/doomemacs/doomemacs) - For Emacs users looking for evil-mode. Enable the `markdown` module in your config

Terminal editors can integrate the same validation tools used by the pre-commit hooks directly into your editing workflow:

- [markdownlint](https://github.com/DavidAnson/markdownlint)
- [vale](https://github.com/errata-ai/vale)
- [harper-ls](https://github.com/Automattic/harper)
- [ltex-ls](https://github.com/valentjn/ltex-ls)

### Rocky Linux 10 setup

If you are running Rocky Linux 10, follow these steps to set up a complete documentation validation environment. This installs all required tools and enables you to run the same checks that the Documentation Team uses to validate pull requests.

#### Step 1: Install system dependencies

```bash
# Note: npm is bundled with nodejs in Rocky Linux 10
sudo dnf install -y git python3-pip hunspell hunspell-en-US nodejs
```

#### Step 2: Install Python packages

```bash
pip install pre-commit pyspelling
```

#### Step 3: Install Node.js packages

```bash
sudo npm install -g markdownlint-cli
```

#### Step 4: Install lychee link checker

Lychee is not available in the Rocky Linux repositories, so install the binary directly:

```bash
cd /tmp
curl -sLO https://github.com/lycheeverse/lychee/releases/latest/download/lychee-x86_64-unknown-linux-gnu.tar.gz
tar xzf lychee-x86_64-unknown-linux-gnu.tar.gz
sudo mv lychee /usr/local/bin/
sudo chmod +x /usr/local/bin/lychee
rm -f lychee-x86_64-unknown-linux-gnu.tar.gz
```

Verify the installation:

```bash
lychee --version
```

#### Step 5: Clone your forked repository and configure it

```bash
git clone https://github.com/YOUR_USERNAME/documentation.git
cd documentation
```

If you have already cloned the repository, ensure it is up to date:

```bash
cd documentation
git pull origin main
```

#### Step 6: Verify pyspelling configuration

The repository includes a `.pyspelling.yml` configured for Hunspell, which is the default spell checker on Rocky Linux 10. No additional configuration is needed. Verify that Hunspell is installed:

```bash
rpm -q hunspell hunspell-en-US
```

If not installed:

```bash
sudo dnf install -y hunspell hunspell-en-US
```

#### Step 7: Install pre-commit hooks

```bash
pre-commit install
```

#### Step 8: Verify your setup

Run all validation checks to confirm everything is working:

```bash
pre-commit run --all-files
```

#### Expected behavior on first run

When running `pre-commit run --all-files` for the first time, you may see errors from existing repository files. This is expected behavior:

| Hook | Expected Result | Notes |
|------|-----------------|-------|
| trailing-whitespace | May auto-fix files | Changes are staged automatically |
| end-of-file-fixer | May auto-fix files | Changes are staged automatically |
| check-yaml | Pass | MkDocs config files are excluded |
| check-added-large-files | Pass | |
| markdownlint | May show errors | |
| pyspelling | Pass (with Hunspell config) | Requires Step 6 configuration |
| lychee | Pass | Some timeouts are normal |

**Important**: The markdownlint errors you see are in existing repository documentation files, not files you created. When contributing, you only need to ensure your own files pass validation.

#### Step 9: Validate your document

Before submitting your documentation, validate your specific file to ensure it passes all checks:

```bash
# Spell check
pyspelling -n Markdown -S "docs/guides/your-document.md"

# Markdown lint
markdownlint "docs/guides/your-document.md"

# Link check
lychee "docs/guides/your-document.md" --no-progress
```

Example output for a passing spell check:

```text
pyspelling -n Markdown -S "docs/guides/hpc/slurm-rocky.md"
Spelling check passed :)
```

Example output for a failing markdown lint check:

```text
markdownlint docs/guides/automation/kickstart-rocky-broken.md
docs/guides/automation/kickstart-rocky-broken.md:1 error MD041/first-line-heading/first-line-h1 First line in a file should be a top-level heading [Context: "---"]
docs/guides/automation/kickstart-rocky-broken.md:162 error MD001/heading-increment Heading levels should only increment by one level at a time [Expected: h2; Actual: h3]
```

Example output for a passing link check:

```text
lychee docs/guides/hpc/slurm-rocky.md --no-progress
🔍 8 Total (in 0s) ✅ 8 OK 🚫 0 Errors
```

### Rocky Linux 9 setup

If you are running Rocky Linux 9, follow these steps to set up a complete documentation validation environment. Rocky Linux 9 uses Hunspell for spell checking (aspell is not available in EPEL for Rocky Linux 9).

#### Step 1: Install system dependencies

```bash
sudo dnf install -y git python3-pip hunspell hunspell-en-US nodejs npm
```

#### Step 2: Install Python packages

```bash
pip install --user pre-commit pyspelling
```

#### Step 3: Install Node.js packages

```bash
sudo npm install -g markdownlint-cli
```

#### Step 4: Install lychee link checker

Lychee is not available in the Rocky Linux repositories, so install the binary directly:

```bash
cd /tmp
curl -sLO https://github.com/lycheeverse/lychee/releases/latest/download/lychee-x86_64-unknown-linux-gnu.tar.gz
tar xzf lychee-x86_64-unknown-linux-gnu.tar.gz
sudo mv lychee /usr/local/bin/
sudo chmod +x /usr/local/bin/lychee
rm -f lychee-x86_64-unknown-linux-gnu.tar.gz
```

Verify the installation:

```bash
lychee --version
```

#### Step 5: Clone your forked repository and configure it

```bash
git clone https://github.com/YOUR_USERNAME/documentation.git
cd documentation
```

#### Step 6: Verify pyspelling configuration

The repository includes a `.pyspelling.yml` configured for Hunspell, which is the default spell checker on Rocky Linux 9. No additional configuration is needed. Verify that Hunspell is installed:

```bash
rpm -q hunspell hunspell-en-US
```

If not installed:

```bash
sudo dnf install -y hunspell hunspell-en-US
```

#### Step 7: Install pre-commit hooks

```bash
~/.local/bin/pre-commit install
```

**Note**: When using `pip install --user`, the `pre-commit` binary is installed to `~/.local/bin/`. You can either use the full path or add `~/.local/bin` to your PATH:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

#### Step 8: Verify your setup

Run all validation checks to confirm everything is working:

```bash
~/.local/bin/pre-commit run --all-files
```

#### Step 9: Validate your document

Before submitting your documentation, validate your specific file to ensure it passes all checks:

```bash
# Spell check
pyspelling -n Markdown -S "docs/guides/your-document.md"

# Markdown lint
markdownlint "docs/guides/your-document.md"

# Link check
lychee "docs/guides/your-document.md" --no-progress
```

### Rocky Linux 8 setup

If you are running Rocky Linux 8, follow these steps to set up a complete documentation validation environment. Rocky Linux 8 uses Aspell for spell checking (available from base repositories).

#### Step 1: Install system dependencies

Rocky Linux 8 uses Python 3.9 and Node.js module streams:

```bash
# Install Python 3.9 and other dependencies
sudo dnf install -y git python39-pip python39 aspell aspell-en

# Enable Node.js 18 module stream
sudo dnf module enable -y nodejs:18

# Install Node.js
sudo dnf install -y nodejs
```

#### Step 2: Install Python packages

Use Python 3.9's pip:

```bash
pip3.9 install --user pre-commit pyspelling
```

#### Step 3: Install Node.js packages

```bash
sudo npm install -g markdownlint-cli
```

#### Step 4: Install lychee link checker

Lychee is not available in the Rocky Linux repositories, so install the binary directly:

```bash
cd /tmp
curl -sLO https://github.com/lycheeverse/lychee/releases/latest/download/lychee-x86_64-unknown-linux-gnu.tar.gz
tar xzf lychee-x86_64-unknown-linux-gnu.tar.gz
sudo mv lychee /usr/local/bin/
sudo chmod +x /usr/local/bin/lychee
rm -f lychee-x86_64-unknown-linux-gnu.tar.gz
```

Verify the installation:

```bash
lychee --version
```

#### Step 5: Clone your forked repository and configure it

```bash
git clone https://github.com/YOUR_USERNAME/documentation.git
cd documentation
```

#### Step 6: Configure pyspelling for Aspell

The repository `.pyspelling.yml` is configured for Hunspell by default. Rocky Linux 8 uses Aspell instead, so you need to create a local override. Create a `.pyspelling.yml` file in the repository root:

```bash
cat > .pyspelling.yml << 'EOF'
spellchecker: aspell
matrix:
  - name: Markdown
    sources:
      # Process English files only - exclude translations
      - 'docs/**/*.md|!docs/**/*.{af,de,en,es,fr,hi,id,it,ja,ko,pl,pt,pt-BR,sv,tr,uk,zh}.md'
    expect_match: false
    aspell:
      lang: en
      d: en_US
    dictionary:
      wordlists:
        - .wordlist.txt
      output: build/spelling-wordlist.dic
    pipeline:
      - pyspelling.filters.markdown:
      - pyspelling.filters.html:
          comments: true
          ignores:
            - code
            - pre
            - kbd
      - pyspelling.filters.context:
          context_visible_first: true
          escapes: '\\[\\`]'
          delimiters:
            # Ignore front matter
            - open: '(?s)^---'
              close: '^---'
            # Ignore code blocks
            - open: '(?s)^(?P<open>`{3,}).*$'
              close: '^(?P=open)$'
            # Ignore inline code
            - open: '`'
              close: '`'
            # Ignore URLs
            - open: '\('
              content: 'https?://[^\)]*'
              close: '\)'
            # Ignore email addresses
            - open: '<'
              content: '[^>]+@[^>]+'
              close: '>'
      - pyspelling.filters.url:
EOF
```

After creating the override, tell Git to ignore your local changes to this file so you do not accidentally commit it:

```bash
git update-index --assume-unchanged .pyspelling.yml
```

This prevents the modified `.pyspelling.yml` from appearing in `git status` or being staged by `git add`. If you ever need to undo this (for example, to pull upstream changes to the file), run:

```bash
git update-index --no-assume-unchanged .pyspelling.yml
```

#### Step 7: Install pre-commit hooks

```bash
~/.local/bin/pre-commit install
```

**Note**: When using `pip install --user`, the `pre-commit` binary is installed to `~/.local/bin/`. You can either use the full path or add `~/.local/bin` to your PATH:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

#### Step 8: Verify your setup

Run all validation checks to confirm everything is working:

```bash
~/.local/bin/pre-commit run --all-files
```

#### Step 9: Validate your document

Before submitting your documentation, validate your specific file to ensure it passes all checks:

```bash
# Spell check
pyspelling -n Markdown -S "docs/guides/your-document.md"

# Markdown lint
markdownlint "docs/guides/your-document.md"

# Link check
lychee "docs/guides/your-document.md" --no-progress
```

### macOS Sequoia setup

If you are running macOS Sequoia (macOS 15), follow these steps to set up a complete documentation validation environment. These instructions have been tested on both Apple Silicon (M1/M2/M3/M4) and Intel Macs.

#### Step 1: Install Xcode command line tools

Before installing Homebrew, you must install the Xcode Command Line Tools:

```bash
xcode-select --install
```

A dialog box will appear asking you to install the tools. Click **Install** and wait for the installation to complete.

#### Step 2: Install Homebrew (if not already installed)

If you do not have [Homebrew](https://brew.sh/) installed, run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Important for Apple Silicon Macs (M1/M2/M3/M4)**: Homebrew installs to `/opt/homebrew` on Apple Silicon, which is not in the default PATH. After installation, run these commands to configure your shell:

```bash
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Verify Homebrew is working:

```bash
brew doctor
```

**Note for Intel Macs**: Homebrew installs to `/usr/local` on Intel Macs, which is already in the default PATH. No additional configuration is needed.

#### Step 3: Install system dependencies

```bash
brew install git python node aspell lychee
```

#### Step 4: Install Python packages

The recommended approach is to use a virtual environment:

```bash
python3 -m venv ~/rocky-docs-env
source ~/rocky-docs-env/bin/activate
pip install pre-commit pyspelling
```

Add an alias to your shell configuration for easy activation:

```bash
echo "alias rocky-docs-env='source ~/rocky-docs-env/bin/activate'" >> ~/.zshrc
source ~/.zshrc
```

#### Step 5: Install Node.js packages

If you encounter permission errors with npm global installs, configure npm to use a user directory:

```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Then install markdownlint:

```bash
npm install -g markdownlint-cli
```

#### Step 6: Clone your forked repository and configure it

```bash
git clone https://github.com/YOUR_USERNAME/documentation.git
cd documentation
```

Add the upstream remote:

```bash
git remote add upstream https://github.com/rocky-linux/documentation.git
```

#### Step 7: Configure pyspelling for macOS

The repository `.pyspelling.yml` is configured for Hunspell by default. macOS uses Aspell (installed via Homebrew), so you need to create a local override. Create a `.pyspelling.yml` file in the repository root configured for Aspell:

```bash
cat > .pyspelling.yml << 'EOF'
spellchecker: aspell
matrix:
  - name: Markdown
    sources:
      - 'docs/**/*.md'
    expect_match: false
    aspell:
      lang: en
      d: en_US
    dictionary:
      wordlists:
        - .wordlist.txt
      output: build/spelling-wordlist.dic
    pipeline:
      - pyspelling.filters.markdown
      - pyspelling.filters.html:
          ignores:
            - code
            - pre
            - kbd
      - pyspelling.filters.context:
          context_visible_first: true
          escapes: '\\[\\`]'
          delimiters:
            - open: '(?s)^---'
              close: '^---'
            - open: '(?s)^(?P<open>`{3,}).*$'
              close: '^(?P=open)$'
            - open: '`'
              close: '`'
            - open: '\('
              content: 'https?://[^\)]*'
              close: '\)'
            - open: '<'
              content: '[^>]+@[^>]+'
              close: '>'
      - pyspelling.filters.url
EOF
```

After creating the override, tell Git to ignore your local changes to this file so you do not accidentally commit it:

```bash
git update-index --assume-unchanged .pyspelling.yml
```

This prevents the modified `.pyspelling.yml` from appearing in `git status` or being staged by `git add`. If you ever need to undo this (for example, to pull upstream changes to the file), run:

```bash
git update-index --no-assume-unchanged .pyspelling.yml
```

#### Step 8: Install pre-commit hooks

```bash
pre-commit install
```

#### Step 9: Verify your setup

Run the validation checks:

```bash
pre-commit run --all-files
```

**Note**: The pyspelling (spell check) and lychee (link check) hooks are configured as manual hooks to avoid long run times on the full repository. When running `pre-commit run --all-files`, you may see markdownlint errors from existing repository files. These are pre-existing issues and are not your responsibility to fix.

#### Validating your own documents

When contributing, validate your specific document using these commands:

```bash
# Activate the virtual environment first
rocky-docs-env

# Markdown lint check
markdownlint docs/guides/your-document.md

# Spell check
pyspelling -n Markdown -S docs/guides/your-document.md

# Link check
lychee docs/guides/your-document.md --no-progress
```

### Windows 11 setup

If you are running Windows 11, follow these steps to set up a complete documentation validation environment.

#### Step 1: Install Chocolatey package manager

Open **PowerShell as Administrator** (right-click Start → Terminal (Admin)) and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
iwr https://community.chocolatey.org/install.ps1 -UseBasicParsing | iex
```

Close and reopen PowerShell as Administrator after installation.

#### Step 2: Install Git, Python, and Node.js

```powershell
choco install -y git python nodejs-lts
```

Close and reopen PowerShell as Administrator to refresh the PATH.

#### Step 3: Install Python packages

```powershell
pip install pre-commit pyspelling
```

#### Step 4: Install Node.js packages

```powershell
npm install -g markdownlint-cli
```

#### Step 5: Install Hunspell (spell checker)

```powershell
choco install -y hunspell.portable
```

#### Step 6: Install lychee (link checker)

```powershell
choco install -y lychee
```

#### Step 7: Clone your forked repository and configure it

```powershell
cd ~\Documents
git clone https://github.com/YOUR_USERNAME/documentation.git
cd documentation
```

#### Step 8: Create pre-commit configuration

Create a `.pre-commit-config.yaml` file in the repository root:

```powershell
@"
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
        args: [--markdown-linebreak-ext=md]
      - id: end-of-file-fixer
      - id: check-yaml
        exclude: |
          (?x)^(
            tools/mkdocs-docker\.yml|
            tools/docker-compose\.yml|
            build_pdf/build_base\.yml|
            mkdocs\.yml
          )$
      - id: check-added-large-files
        args: ['--maxkb=1024']

  - repo: https://github.com/igorshubovych/markdownlint-cli
    rev: v0.38.0
    hooks:
      - id: markdownlint
        args:
          - --config
          - .markdownlint.yml
          - --fix
        files: \.md$
        exclude: |
          (?x)^(
            LICENSE\.md|
            build_pdf/.*
          )$
"@ | Out-File -FilePath .pre-commit-config.yaml -Encoding UTF8
```

#### Step 9: Install pre-commit hooks

```powershell
pre-commit install
```

#### Step 10: Verify your setup

Run validation checks to confirm everything is working:

```powershell
pre-commit run --files docs/guides/automation/kickstart-rocky.md
```

### Install pre-commit hooks

Pre-commit hooks run automatically before each commit to check spelling, markdown formatting, and links. If you followed one of the platform-specific setup guides above, you have already completed this step.

For other platforms not listed above, here are the general instructions:

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
# On Rocky Linux 10 (binary installation - lychee is not in repos):
cd /tmp && curl -sLO https://github.com/lycheeverse/lychee/releases/latest/download/lychee-x86_64-unknown-linux-gnu.tar.gz
tar xzf lychee-x86_64-unknown-linux-gnu.tar.gz && sudo mv lychee /usr/local/bin/
sudo chmod +x /usr/local/bin/lychee && rm -f lychee-x86_64-unknown-linux-gnu.tar.gz

# On Fedora (may be available in repos):
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

## Creating new documentation

### Document naming

Use lowercase filenames with underscores or hyphens. Keep names short and descriptive:

- `kickstart_rocky.md` - Good
- `HowToInstallRockyLinuxUsingKickstart.md` - Too long
- `ks.md` - Too vague

For translated documents, append the language code before `.md`:

- `kickstart_rocky.md` - English (default)
- `kickstart_rocky.de.md` - German
- `kickstart_rocky.es.md` - Spanish

### Document location

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

### Document structure

Every document must include front matter metadata at the top:

```yaml
---
title: Your Document Title
author: Your Name
contributors: Comma, Separated, Names
tested_with: 8.10, 9.7, 10.1
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

### Example guides

Feel free to take a look at some example guides to understand the formatting and styling:

- [Kickstart Files and Rocky Linux](../automation/kickstart-rocky.md)
- [Setting Up libvirt on Rocky Linux](../virtualization/libvirt-rocky.md)
- [Automatic template creation with Packer and deployment with Ansible in a VMware vSphere environment](../automation/templates-automation-packer-vsphere.md)

### AI usage

The Rocky Linux Documentation Team permits AI and LLM tools in the contribution process, following the [Fedora AI Policy](https://docs.fedoraproject.org/en-US/docs/ai-policy/) as a baseline. If you use AI for any part of your documentation (drafting, research, grammar, code generation), you must include a disclosure at the beginning of your document stating that AI was used and that you take full responsibility for correctness of the content. You must test every procedure and verify all technical content yourself, as AI frequently produces errors. Do not pass other contributors' existing work through AI tools and resubmit it as a contribution, as this erases the original author's voice. Minor corrections such as typos and broken links do not require disclosure.

## Formatting guidelines

### Style guide

Follow the [Rocky Linux style guide](style_guide.md) for:

- Grammar and punctuation standards
- Voice and tone guidelines
- Accessibility requirements

Key points:

- Use US English spelling
- Use active voice
- Avoid contractions (aids translation)
- Use sentence-style capitalization for headings
- Use serial commas ("apples, oranges, and bananas")

### Markdown formatting

Follow the [Document formatting guide](rockydocs_formatting.md) for:

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

### Code blocks

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

## Validation checks

Before committing, the pre-commit hooks automatically run:

1. **Spell check** (pyspelling) - Checks for US English spelling errors
2. **Markdown lint** (markdownlint) - Validates markdown formatting
3. **Link check** (lychee) - Verifies all links are valid

If any check fails, the commit is blocked. Fix the issues and try again.

### Running checks manually

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

### Rocky docs contribution guidelines validation

Beyond the standard checks, your document must comply with the [Rocky Linux documentation contribution guidelines](beginners.md) and [formatting standards](rockydocs_formatting.md). Use the following checks to validate your document before submitting a pull request.

#### Validate a single document

Replace `path/to/your-document.md` with your document path in all commands below.

**Run standard checks on your document:**

```bash
# Spell check
pyspelling -n Markdown -S "path/to/your-document.md"

# Markdown lint
markdownlint "path/to/your-document.md"

# Link check
lychee "path/to/your-document.md" --no-progress
```

#### Metadata validation

Every document requires front matter metadata. Check that your document includes:

| Field | Required | Description |
|-------|----------|-------------|
| `title` | Yes | Document title |
| `author` | Yes | Your name |
| `contributors` | Recommended | Comma-separated list of contributors |
| `tested_with` | Yes | Rocky Linux versions tested (e.g., `8.10, 9.7, 10.1`) |
| `tags` | Yes | Searchable one-word terms |

**Check for required metadata:**

```bash
# Check for title
grep -q '^title:' path/to/your-document.md && echo "✓ Title found" || echo "✗ Missing title"

# Check for author
grep -q '^author:' path/to/your-document.md && echo "✓ Author found" || echo "✗ Missing author"

# Check for contributors (recommended)
grep -q '^contributors:' path/to/your-document.md && echo "✓ Contributors found" || echo "⚠ Contributors recommended"

# Check for tested with
grep -qE '^tested.*(with|_with|on)?:' path/to/your-document.md && echo "✓ Tested with found" || echo "✗ Missing tested with"

# Check for tags
grep -q '^tags:' path/to/your-document.md && echo "✓ Tags found" || echo "✗ Missing tags"
```

#### Heading structure validation

Documents should have at most one Level 1 heading (`#`). If your document has `title:` metadata, the title is auto-generated, so you may not need a Level 1 heading at all.

```bash
# Count Level 1 headings (should be 0 or 1)
h1_count=$(grep -c '^# ' path/to/your-document.md || echo 0)
if [ "$h1_count" -le 1 ]; then
    echo "✓ Heading structure OK ($h1_count H1 headings)"
else
    echo "✗ Too many H1 headings: $h1_count (maximum 1 allowed)"
fi
```

#### Admonition formatting

Admonitions use the `!!!` syntax with proper types and 4-space indentation for content:

```markdown
!!! warning "Optional Custom Title"

    This content must be indented with 4 spaces.
```

Valid admonition types: `note`, `abstract`, `info`, `tip`, `success`, `question`, `warning`, `failure`, `danger`, `bug`, `example`, `quote`

```bash
# Check admonition syntax
if grep -qE '^!!!\s+(note|abstract|info|tip|success|question|warning|failure|danger|bug|example|quote)' path/to/your-document.md; then
    echo "✓ Admonitions use valid types"
else
    if grep -q '^!!!' path/to/your-document.md; then
        echo "⚠ Admonitions found but may have invalid types"
    else
        echo "ℹ No admonitions found"
    fi
fi
```

#### Code block validation

Code blocks must specify a language identifier for syntax highlighting:

````markdown
```bash
dnf install httpd
```
````

```bash
# Check for code blocks without language identifiers
blocks_without_lang=$(grep -c '^```$' path/to/your-document.md 2>/dev/null || echo 0)
blocks_with_lang=$(grep -c '^```[a-zA-Z]' path/to/your-document.md 2>/dev/null || echo 0)

if [ "$blocks_without_lang" -eq 0 ]; then
    echo "✓ All code blocks have language identifiers ($blocks_with_lang blocks)"
else
    echo "✗ $blocks_without_lang code blocks missing language identifiers"
fi
```

#### Link format validation

Links should use proper markdown format `[text](url)`. Avoid bare URLs.

```bash
# Count properly formatted links
proper_links=$(grep -oE '\[[^]]+\]\([^)]+\)' path/to/your-document.md 2>/dev/null | wc -l)
echo "ℹ Found $proper_links properly formatted links"
```

#### Lab domain validation

When using example URLs in documentation, use approved domains to pass link validation:

- `example.com`, `example.org`, `example.net`
- `home.arpa`
- `localhost` or `127.0.0.1`

#### Internal anchors warning

Avoid internal document anchors like `[link](#section-name)` as they may break during translation.

```bash
# Check for internal anchors
anchors=$(grep -cE '\[.+\]\(#[^)]+\)' path/to/your-document.md 2>/dev/null || echo 0)
if [ "$anchors" -eq 0 ]; then
    echo "✓ No internal anchors found"
else
    echo "⚠ Found $anchors internal anchors (may break during translation)"
fi
```

#### Raw HTML warning

Avoid using raw HTML elements. Markdown linters flag them and they may not render correctly. The following HTML elements are allowed in `.markdownlint.yml` and will not trigger linting errors:

- `<sub>` and `<sup>` - For subscript and superscript text
- `<details>` and `<summary>` - For collapsible/expandable content sections

```bash
# Check for HTML tags (excluding allowed elements: sub, sup, details, summary)
html_tags=$(grep -cE '<(?!sub|sup|details|summary|/sub|/sup|/details|/summary)[a-zA-Z][^>]*>' path/to/your-document.md 2>/dev/null || echo 0)
if [ "$html_tags" -eq 0 ]; then
    echo "✓ No disallowed raw HTML found"
else
    echo "⚠ Found $html_tags HTML tags (use markdown instead, or allowed elements: sub, sup, details, summary)"
fi
```

#### Complete validation script

Save this script as `validate-doc.sh` and run it against your document:

```bash
#!/bin/bash
# Rocky Linux Documentation Validator
# Usage: ./validate-doc.sh path/to/your-document.md

if [ -z "$1" ]; then
    echo "Usage: $0 <path-to-markdown-file>"
    exit 1
fi

DOC="$1"

if [ ! -f "$DOC" ]; then
    echo "Error: File not found: $DOC"
    exit 1
fi

echo "============================================"
echo "ROCKY LINUX DOCUMENTATION VALIDATOR"
echo "============================================"
echo "Document: $DOC"
echo "--------------------------------------------"
echo ""
echo "METADATA CHECKS:"
echo "--------------------------------------------"
grep -q '^title:' "$DOC" && echo "  Title:        ✓ PASS" || echo "  Title:        ✗ FAIL - Required"
grep -q '^author:' "$DOC" && echo "  Author:       ✓ PASS" || echo "  Author:       ✗ FAIL - Required"
grep -q '^contributors:' "$DOC" && echo "  Contributors: ✓ PASS" || echo "  Contributors: ⚠ WARN - Recommended"
grep -qE '^tested.*(with|_with|on)?:' "$DOC" && echo "  Tested With:  ✓ PASS" || echo "  Tested With:  ✗ FAIL - Required"
grep -q '^tags:' "$DOC" && echo "  Tags:         ✓ PASS" || echo "  Tags:         ✗ FAIL - Required"
echo ""
echo "STRUCTURE CHECKS:"
echo "--------------------------------------------"
h1_count=$(grep -c '^# ' "$DOC" 2>/dev/null || echo 0)
if [ "$h1_count" -le 1 ]; then
    echo "  Single H1:    ✓ PASS ($h1_count heading)"
else
    echo "  Single H1:    ✗ FAIL - Found $h1_count (max 1)"
fi
echo ""
echo "FORMATTING CHECKS:"
echo "--------------------------------------------"
blocks_without_lang=$(grep -c '^```$' "$DOC" 2>/dev/null || echo 0)
if [ "$blocks_without_lang" -eq 0 ]; then
    echo "  Code Blocks:  ✓ PASS"
else
    echo "  Code Blocks:  ✗ FAIL - $blocks_without_lang missing language"
fi

anchors=$(grep -cE '\[.+\]\(#[^)]+\)' "$DOC" 2>/dev/null || echo 0)
if [ "$anchors" -eq 0 ]; then
    echo "  No Anchors:   ✓ PASS"
else
    echo "  No Anchors:   ⚠ WARN - $anchors found (translation risk)"
fi

html_tags=$(grep -cE '<(?!sub|sup|details|summary|/sub|/sup|/details|/summary)[a-zA-Z][^>]*>' "$DOC" 2>/dev/null || echo 0)
if [ "$html_tags" -eq 0 ]; then
    echo "  No Raw HTML:  ✓ PASS (sub, sup, details, summary are allowed)"
else
    echo "  No Raw HTML:  ⚠ WARN - $html_tags disallowed tags found"
fi
echo ""
echo "TOOL CHECKS:"
echo "--------------------------------------------"
echo "Running pyspelling..."
if pyspelling -n Markdown -S "$DOC" > /dev/null 2>&1; then
    echo "  Spell Check:  ✓ PASS"
else
    echo "  Spell Check:  ✗ FAIL - Run: pyspelling -n Markdown -S \"$DOC\""
fi

echo "Running markdownlint..."
if markdownlint "$DOC" > /dev/null 2>&1; then
    echo "  Markdown:     ✓ PASS"
else
    echo "  Markdown:     ✗ FAIL - Run: markdownlint \"$DOC\""
fi

echo "Running lychee..."
if lychee "$DOC" --no-progress > /dev/null 2>&1; then
    echo "  Links:        ✓ PASS"
else
    echo "  Links:        ✗ FAIL - Run: lychee \"$DOC\" --no-progress"
fi
echo ""
echo "============================================"
```

Make the script executable and run it:

```bash
chmod +x validate-doc.sh
./validate-doc.sh docs/guides/automation/kickstart-rocky.md
```

Example output:

```text
============================================
ROCKY LINUX DOCUMENTATION VALIDATOR
============================================
Document: docs/guides/automation/kickstart-rocky.md
--------------------------------------------

METADATA CHECKS:
--------------------------------------------
  Title:        ✓ PASS
  Author:       ✓ PASS
  Contributors: ✓ PASS
  Tested With:  ✓ PASS
  Tags:         ✓ PASS

STRUCTURE CHECKS:
--------------------------------------------
  Single H1:    ✓ PASS (1 heading)

FORMATTING CHECKS:
--------------------------------------------
  Code Blocks:  ✓ PASS
  No Anchors:   ✓ PASS
  No Raw HTML:  ✓ PASS

TOOL CHECKS:
--------------------------------------------
Running pyspelling...
  Spell Check:  ✓ PASS
Running markdownlint...
  Markdown:     ✓ PASS
Running lychee...
  Links:        ✓ PASS

============================================
```

### Adding words to the dictionary

If the spell checker flags a valid technical term, add it to `.wordlist.txt` in alphabetical order. Common additions include:

- Rocky Linux specific terms
- Package names
- Technical acronyms
- Command names

**Important**: Do not include `.wordlist.txt` changes in your pull request. Keep your wordlist additions local to your machine. The documentation team maintains the shared `.wordlist.txt` and will add any necessary terms during the review process. When staging files for your commit, only add your document:

```bash
# Only stage your document, not the wordlist
git add docs/guides/your-document.md
```

If you have already staged `.wordlist.txt` by mistake, unstage it before committing:

```bash
git restore --staged .wordlist.txt
```

## Submitting a pull request

### Pushing your changes to the Rocky Linux documentation repository

1. Sync your fork with upstream:

```bash
git fetch upstream
git checkout main
git merge upstream/main
```

2. Create a branch for your changes:

```bash
git checkout -b your-new-document
```

3. Add your document and commit:

```bash
git add docs/guides/your-document.md
git commit -m "Add new document for your-document"
```

4. Push and create a pull request:

```bash
git push origin your-new-document
```

> **Note:** You can also edit existing documentation and push your changes to the Rocky Linux Documentation repository using the same method.

## Getting help

The Rocky Linux community is welcoming and supportive of contributors of all experience levels. Do not hesitate to ask for help.

- **Mattermost**: Join the [Documentation channel](https://chat.rockylinux.org/rocky-linux/channels/documentation) and the community of contributors will be more than happy to help you with your document
- **GitHub Issues**: Report documentation bugs or suggest improvements
- **Forums**: Visit the [Rocky Linux Forums](https://forums.rockylinux.org) for general questions

If you are unsure where to start, or if something in this guide is unclear, just ask. Someone will point you in the right direction.

## Additional resources

- [Style guide](style_guide.md) - Writing standards
- [Document formatting](rockydocs_formatting.md) - Markdown syntax and admonitions
- [Beginner contributors guide](beginners.md) - Detailed walkthrough for new contributors
- [Creating new documents](createnew.md) - GitHub-specific instructions
- [Navigation and structure](navigation.md) - How the documentation site is organized

## License

Documents contributed to Rocky Linux documentation are published under the [Creative Commons BY-SA 4.0 license](https://creativecommons.org/licenses/by-sa/4.0/). By contributing, you agree to license your work under these terms.
